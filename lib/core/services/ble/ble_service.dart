import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

/// UUIDs for the NIA WLC BLE service/characteristics (Nordic UART Service).
const String kNiaBleServiceUuid  = '6e400001-b5a3-f393-e0a9-e50e24dcca9e'; // Service
const String kNiaBleWriteUuid    = '6e400002-b5a3-f393-e0a9-e50e24dcca9e'; // Write (TX to device)
const String kNiaBleNotifyUuid   = '6e400003-b5a3-f393-e0a9-e50e24dcca9e'; // Notify (RX from device)

/// Prefix that all NIA WLC devices advertise.
const String kNiaDeviceNamePrefix = 'NIA_';

/// Converts BLE remote-id (MAC "2C:CF:67:4C:0F:8B") to our deviceId
/// format ("2CCF674C0F8A") so it matches [ControllerEntity.deviceId].
String bleRemoteIdToDeviceId(String remoteId) =>
    remoteId.replaceAll(':', '').toUpperCase();

/// Reverse: our deviceId → BLE name suffix so we can match during scan.
/// Device name is "NIA_2CCF674C0F8A", deviceId is "2CCF674C0F8A".
String deviceIdToBleNameSuffix(String deviceId) => deviceId.toUpperCase();

enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

class BleDeviceConnection {
  final BluetoothDevice device;

  /// 6E400002 — used to send commands TO the device.
  BluetoothCharacteristic? _writeCharacteristic;

  /// 6E400003 — used to receive notifications FROM the device.
  BluetoothCharacteristic? _notifyCharacteristic;

  StreamSubscription? _notifySubscription;
  final StreamController<String> _incomingController =
  StreamController<String>.broadcast();

  // ── Reassembly state ──────────────────────────────────────────────────
  // BLE notifications are MTU-limited (commonly ~20-244 bytes per packet),
  // so a single JSON payload from the device frequently arrives split
  // across multiple notification events. We buffer raw bytes and only
  // emit a complete message once we see a balanced `{ ... }` JSON object
  // (brace-depth tracking, ignoring braces that appear inside quoted
  // string values).
  final List<int> _rxBuffer = [];
  int _braceDepth = 0;
  bool _inMessage = false; // true once we've seen the opening '{'
  bool _inString = false;
  bool _escapeNext = false;
  static const int _maxBufferBytes = 8192; // safety cap to avoid unbounded growth

  Stream<String> get incoming => _incomingController.stream;
  bool get isConnected =>
      device.isConnected &&
          _writeCharacteristic != null &&
          _notifyCharacteristic != null;

  BleDeviceConnection(this.device);

  Future<void> setupCharacteristic() async {
    final services = await device.discoverServices();

    for (final service in services) {
      if (service.uuid.toString().toLowerCase() == kNiaBleServiceUuid) {
        for (final char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();

          // ── Write characteristic (TX → device) ──────────────────────────
          if (uuid == kNiaBleWriteUuid) {
            _writeCharacteristic = char;
            if (kDebugMode) kdebugmode('BLE: Write characteristic found');
          }

          // ── Notify characteristic (RX ← device) ─────────────────────────
          if (uuid == kNiaBleNotifyUuid) {
            _notifyCharacteristic = char;
            if (char.properties.notify) {
              await char.setNotifyValue(true);
              _notifySubscription = char.lastValueStream.listen(_onChunk);

              if (kDebugMode) kdebugmode('BLE: Notify characteristic subscribed');
            }
          }
        }
        break; // correct service found — no need to check others
      }
    }

    if (_writeCharacteristic == null || _notifyCharacteristic == null) {
      throw Exception(
          'NIA WLC BLE characteristics not found. '
              'Write: ${_writeCharacteristic != null}, '
              'Notify: ${_notifyCharacteristic != null}');
    }
  }

  /// Handles a single raw BLE notification chunk. Chunks are appended to
  /// an internal buffer; a complete message is only emitted once a full
  /// `{...}` JSON object has been accumulated, regardless of how many
  /// BLE fragments it was split across.
  void _onChunk(List<int> bytes) {
    if (bytes.isEmpty) return;

    // Reset buffer for every new packet/chunk
    _rxBuffer.clear();
    _rxBuffer.addAll(bytes);

    if (kDebugMode) {
      kdebugmode('BLE RX chunk (${_rxBuffer.length} bytes): $_rxBuffer');
    }

    final raw = utf8.decode(_rxBuffer, allowMalformed: true).trim();

    if (kDebugMode) {
      kdebugmode('BLE RX raw: $raw');
    }

    if (raw.isNotEmpty) {
      _incomingController.add(raw);
    }
  }
  Future<void> write(String message) async {
    if (_writeCharacteristic == null) {
      throw Exception('BLE write characteristic not ready');
    }
    final bytes = utf8.encode(message);
    if (kDebugMode) kdebugmode('BLE TX: $message');
    // Use writeWithoutResponse if supported (faster); fall back to with-response.
    if (_writeCharacteristic!.properties.writeWithoutResponse) {
      await _writeCharacteristic!.write(bytes, withoutResponse: true);
    } else {
      await _writeCharacteristic!.write(bytes);
    }
  }

  Future<void> dispose() async {
    await _notifySubscription?.cancel();
    await _incomingController.close();
    _rxBuffer.clear();
    try {
      await device.disconnect();
    } catch (_) {}
  }
}

/// Manages scanning, connecting, and communicating with one BLE device at a time.
/// Mirrors the interface of [MqttService] so the rest of the app stays unchanged.
class BleService {
  BleDeviceConnection? _activeConnection;
  String? _activeDeviceId; // our deviceId format

  final StreamController<BleConnectionState> _stateController =
  StreamController<BleConnectionState>.broadcast();
  Stream<BleConnectionState> get stateStream => _stateController.stream;
  BleConnectionState _state = BleConnectionState.disconnected;
  BleConnectionState get state => _state;

  /// Exposes incoming BLE messages so [BleManager] can pipe them through
  /// [MqttMessageHelper].
  Stream<String> get incomingMessages =>
      _activeConnection?.incoming ?? const Stream.empty();

  /// Scans for a device matching [targetDeviceId] and connects.
  /// Safe to call multiple times — ignores if already connected to same device.
  Future<void> connectToDevice(String targetDeviceId) async {
    if (_activeDeviceId == targetDeviceId &&
        _state == BleConnectionState.connected) {
      return;
    }
    await _disconnect();

    _emit(BleConnectionState.scanning);

    await _requestPermissions();

    if (!await FlutterBluePlus.isSupported) {
      _emit(BleConnectionState.error);
      throw Exception('Bluetooth not supported on this device');
    }

    // Ensure BT is on (Android only)
    if (await FlutterBluePlus.adapterState.first ==
        BluetoothAdapterState.off) {
      _emit(BleConnectionState.error);
      throw Exception('Bluetooth is off');
    }

    final targetSuffix = deviceIdToBleNameSuffix(targetDeviceId);
    BluetoothDevice? found;

    // ── 1. Check already-connected system devices (instant) ───────────────
    final systemDevices = await FlutterBluePlus.systemDevices([]);
    for (final d in systemDevices) {
      final name = d.platformName.toUpperCase();
      if (name.startsWith(kNiaDeviceNamePrefix.toUpperCase()) &&
          name.endsWith(targetSuffix)) {
        found = d;
        break;
      }
    }

    // ── 2. Scan if not found ───────────────────────────────────────────────
    if (found == null) {
      final Completer<BluetoothDevice?> scanCompleter = Completer();
      StreamSubscription? scanSub;

      scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final name = r.device.platformName.toUpperCase();
          if (name.startsWith(kNiaDeviceNamePrefix.toUpperCase()) &&
              name.endsWith(targetSuffix)) {
            scanSub?.cancel();
            if (!scanCompleter.isCompleted) {
              scanCompleter.complete(r.device);
            }
            return;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      found = await scanCompleter.future
          .timeout(const Duration(seconds: 17), onTimeout: () => null);

      await FlutterBluePlus.stopScan().catchError((_) {});
      await scanSub.cancel();
    }

    if (found == null) {
      _emit(BleConnectionState.error);
      throw Exception('Device $targetDeviceId not found during BLE scan');
    }

    // ── 3. Connect ─────────────────────────────────────────────────────────
    _emit(BleConnectionState.connecting);
    _activeConnection = BleDeviceConnection(found);
    _activeDeviceId = targetDeviceId;

    await found.connect(autoConnect: false, license: License.nonprofit);
    // Request larger MTU (Android only; no-op-ish on iOS but harmless to call)
    try {
      await found.requestMtu(247); // or 512, device/stack dependent
    } catch (e) {
      if (kDebugMode) kdebugmode('MTU request failed: $e');
    }


    // Watch for unexpected disconnects
    found.connectionState.listen((connState) {
      if (connState == BluetoothConnectionState.disconnected) {
        if (_state == BleConnectionState.connected) {
          _emit(BleConnectionState.disconnected);
          _activeConnection = null;
          _activeDeviceId = null;
          if (kDebugMode) kdebugmode('BLE: Device disconnected unexpectedly');
        }
      }
    });

    await _activeConnection!.setupCharacteristic();
    _emit(BleConnectionState.connected);

    if (kDebugMode) {
      kdebugmode(
          'BLE CONNECTED -> ${found.platformName} (${found.remoteId})');
    }
  }

  /// Publish a message to the connected BLE device.
  Future<void> publish(String message) async {
    if (_activeConnection == null || _state != BleConnectionState.connected) {
      if (kDebugMode) kdebugmode('BLE publish skipped — not connected');
      return;
    }
    await _activeConnection!.write(message);
  }

  bool get isConnected => _state == BleConnectionState.connected;
  String? get connectedDeviceId => _activeDeviceId;

  Future<void> _disconnect() async {
    await _activeConnection?.dispose();
    _activeConnection = null;
    _activeDeviceId = null;
    _emit(BleConnectionState.disconnected);
  }

  Future<void> disconnect() => _disconnect();

  void _emit(BleConnectionState s) {
    _state = s;
    _stateController.add(s);
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void dispose() {
    _activeConnection?.dispose();
    _stateController.close();
  }
}
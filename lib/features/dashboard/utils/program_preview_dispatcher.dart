import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/mqtt/mqtt_message_helper.dart';

class ProgramPreviewDispatcher extends MessageDispatcher {
  void Function(String deviceId, Map<String, dynamic> message)? onProgramReceived;
  void Function(String deviceId, Map<String, dynamic> message)? onZoneReceived;

  final Map<String, Map<String, dynamic>> _programCache = {};
  final Map<String, List<Map<String, dynamic>>> _zoneCache = {};

  bool _isInitialized = false;
  Future? _initFuture;

  ProgramPreviewDispatcher() {
    _initFuture = _initPersistentCache();
  }

  Future<void> _initPersistentCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('CACHE_PROG_') || k.startsWith('CACHE_ZONES_'));
    for (var key in keys) {
      final parts = key.split('_');
      if (parts.length < 3) continue;
      final deviceId = parts.last;
      final val = prefs.getString(key);
      if (val != null) {
        if (key.startsWith('CACHE_PROG_')) {
          _programCache[deviceId] = jsonDecode(val);
        } else {
          _zoneCache[deviceId] = List<Map<String, dynamic>>.from(jsonDecode(val));
        }
      }
    }
    _isInitialized = true;
  }

  Future<Map<String, dynamic>?> getCachedProgram(String deviceId) async {
    if (!_isInitialized) await _initFuture;
    return _programCache[deviceId];
  }

  Future<List<Map<String, dynamic>>?> getCachedZones(String deviceId) async {
    if (!_isInitialized) await _initFuture;
    return _zoneCache[deviceId];
  }

  Future<void> _saveProgram(String deviceId, Map<String, dynamic> msg) async {
    _programCache[deviceId] = msg;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('CACHE_PROG_$deviceId', jsonEncode(msg));
  }

  Future<void> _saveZone(String deviceId, Map<String, dynamic> msg) async {
    final list = _zoneCache[deviceId] ?? [];
    bool exists = list.any((m) => m['cM'] == msg['cM']);
    if (!exists) {
      list.add(msg);
      _zoneCache[deviceId] = list;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('CACHE_ZONES_$deviceId', jsonEncode(list));
    }
  }

  @override
  void onScheduleOne(String deviceId, Map<String, dynamic> message) {
    _saveProgram(deviceId, message);
    onProgramReceived?.call(deviceId, message);
  }

  @override
  void onScheduleTwo(String deviceId, Map<String, dynamic> message) {
    _saveZone(deviceId, message);
    onZoneReceived?.call(deviceId, message);
  }
}

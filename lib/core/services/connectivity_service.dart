import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetConnection = InternetConnection();
  
  final StreamController<ConnectivityStatus> _statusController = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream.distinct();

  ConnectivityService() {
    _init();
  }

  void _init() {
    // Listen to network interface changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkStatus();
    });

    // Listen to actual internet pings
    _internetConnection.onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.connected) {
        _statusController.add(ConnectivityStatus.online);
      } else {
        _statusController.add(ConnectivityStatus.offline);
      }
    });
  }

  Future<void> _checkStatus() async {
    bool hasConnection = await _internetConnection.hasInternetAccess;
    _statusController.add(hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  Future<bool> checkCurrentStatus() async {
    return await _internetConnection.hasInternetAccess;
  }
}

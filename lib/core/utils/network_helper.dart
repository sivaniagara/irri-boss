import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController.broadcast();

  Stream<bool> get networkStream => _controller.stream;

  void initialise() async {
    // ✅ ADD THIS (initial check)
    final initialStatus = await _hasInternet();
    _controller.add(initialStatus);

    // Listen for changes
    _connectivity.onConnectivityChanged.listen((_) async {
      final isOnline = await _hasInternet();
      _controller.add(isOnline);
    });
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
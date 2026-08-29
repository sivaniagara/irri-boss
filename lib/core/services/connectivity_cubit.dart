import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_service.dart';

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final ConnectivityService _connectivityService;
  StreamSubscription? _subscription;
  Timer? _debounceTimer;

  ConnectivityCubit(this._connectivityService)
      : super(ConnectivityStatus.online) {
    _init();
  }

  void _init() async {
    // Initial check
    bool isOnline = await _connectivityService.checkCurrentStatus();
    emit(isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline);

    // Listen for changes
    _subscription = _connectivityService.connectivityStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        // If we are back online, cancel any pending offline transition and emit immediately
        _debounceTimer?.cancel();
        emit(ConnectivityStatus.online);
      } else {
        // If we are offline, wait for 3 seconds before emitting to avoid flickering
        if (_debounceTimer?.isActive ?? false) return;
        _debounceTimer = Timer(const Duration(seconds: 3), () {
          emit(ConnectivityStatus.offline);
        });
      }
    });
  }

  Future<void> retry() async {
    _debounceTimer?.cancel();
    bool isOnline = await _connectivityService.checkCurrentStatus();
    emit(isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}

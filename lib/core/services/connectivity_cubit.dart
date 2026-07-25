import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_service.dart';

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final ConnectivityService _connectivityService;
  StreamSubscription? _subscription;

  ConnectivityCubit(this._connectivityService) : super(ConnectivityStatus.online) {
    _init();
  }

  void _init() async {
    // Initial check
    bool isOnline = await _connectivityService.checkCurrentStatus();
    emit(isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline);

    // Listen for changes
    _subscription = _connectivityService.connectivityStream.listen((status) {
      emit(status);
    });
  }

  Future<void> retry() async {
    bool isOnline = await _connectivityService.checkCurrentStatus();
    emit(isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';

class ViewPumpSettingsState extends Equatable {
  final bool isLoading;
  final String? settingsJson;
  final String? errorMessage;

  const ViewPumpSettingsState({
    this.isLoading = false,
    this.settingsJson,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, settingsJson, errorMessage];

  ViewPumpSettingsState copyWith({
    bool? isLoading,
    String? settingsJson,
    String? errorMessage,
  }) {
    return ViewPumpSettingsState(
      isLoading: isLoading ?? this.isLoading,
      settingsJson: settingsJson ?? this.settingsJson,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ViewPumpSettingsCubit extends Cubit<ViewPumpSettingsState> {
  ViewPumpSettingsCubit() : super(const ViewPumpSettingsState());

  Timer? _timeoutTimer;

  void requestSettings(String deviceId) {
    emit(state.copyWith(isLoading: true, errorMessage: null, settingsJson: null));

    // Cancel any previous timer
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: "Request timed out. No response from device.",
        ));
      }
    });

    // Publish the request
    sl<MqttManager>().publish(
      deviceId,
      jsonEncode(PublishMessageHelper.pumpViewSettingsRequest),
    );
  }

  void onSettingsReceived(String jsonMessage) {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    emit(state.copyWith(
      isLoading: false,
      settingsJson: jsonMessage,
      errorMessage: null,
    ));
  }

  void setError(String message) {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    emit(state.copyWith(
      isLoading: false,
      errorMessage: message,
      settingsJson: null,
    ));
  }

  @override
  Future<void> close() {
    _timeoutTimer?.cancel();
    return super.close();
  }
}
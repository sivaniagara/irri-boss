import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/pump_settings_urls.dart';

class ViewPumpSettingsState extends Equatable {
  final bool isLoading;
  final String? settingsJson;
  final List<dynamic>? settingLabels;
  final String? errorMessage;

  const ViewPumpSettingsState({
    this.isLoading = false,
    this.settingsJson,
    this.settingLabels,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, settingsJson, settingLabels, errorMessage];

  ViewPumpSettingsState copyWith({
    bool? isLoading,
    String? settingsJson,
    List<dynamic>? settingLabels,
    String? errorMessage,
  }) {
    return ViewPumpSettingsState(
      isLoading: isLoading ?? this.isLoading,
      settingsJson: settingsJson ?? this.settingsJson,
      settingLabels: settingLabels ?? this.settingLabels,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
// view_pump_settings_cubit.dart

class ViewPumpSettingsCubit extends Cubit<ViewPumpSettingsState> {
  ViewPumpSettingsCubit() : super(const ViewPumpSettingsState());

  Timer? _timeoutTimer;
  bool _isExpectingResponse = false;

  void requestSettings(String deviceId, int userId, int subuserId, int controllerId) {
    _timeoutTimer?.cancel();

    _isExpectingResponse = true;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      settingsJson: null,
    ));

    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (_isExpectingResponse && !isClosed) {
        _isExpectingResponse = false;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: "Request timed out. No response from device.",
        ));
      }
    });

    sl<MqttManager>().publish(
      deviceId,
      jsonEncode(PublishMessageHelper.pumpViewSettingsRequest),
    );
  }

  void onSettingsReceived(String jsonMessage) {
    if (!_isExpectingResponse) return;

    _timeoutTimer?.cancel();
    _isExpectingResponse = false;

    emit(state.copyWith(
      isLoading: false,
      settingsJson: jsonMessage,
      errorMessage: null,
    ));
  }

  void setError(String message) {
    _timeoutTimer?.cancel();
    _isExpectingResponse = false;

    emit(state.copyWith(
      isLoading: false,
      errorMessage: message,
      settingsJson: null,
    ));
  }

  Future<List<dynamic>> getSettingLabels(int userId, int subuserId, int controllerId) async {
    final endPoint = buildUrl(
      PumpSettingsUrls.getSettingsMenu,
      {
        "userId": userId,
        "subuserId": subuserId,
        "controllerId": controllerId,
      },
    );

    final response = await sl<ApiClient>().get(endPoint);

    return handleListResponse(
      response,
      fromJson: (json) => json,
    ).fold(
          (failure) => throw ServerException(message: failure.message),
          (list) => list,
    );
  }

  Future<void> loadSettingLabels(int userId, int subuserId, int controllerId) async {
    if (state.settingLabels == null) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final labels = await getSettingLabels(userId, subuserId, controllerId);
      emit(state.copyWith(
        isLoading: false,
        settingLabels: labels,
        errorMessage: state.errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load templates",
      ));
    }
  }

  @override
  Future<void> close() {
    _timeoutTimer?.cancel();
    return super.close();
  }
}
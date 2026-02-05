import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/serial_set/presentation/bloc/serial_set_event.dart';
import 'package:niagara_smart_drip_irrigation/features/serial_set/presentation/bloc/serial_set_state.dart';
import 'package:niagara_smart_drip_irrigation/features/serial_set/domain/repositories/serial_set_repository.dart';

class SerialSetBloc extends Bloc<SerialSetEvent, SerialSetState> {
  final SerialSetRepository repository;

  SerialSetBloc({required this.repository}) : super(SerialSetInitial()) {
    on<FetchSerialSetEvent>(_onFetchSerialSet);
    on<UpdateLoraKeyEvent>(_onUpdateLoraKey);
    on<SendSerialSetMqttEvent>(_onSendSerialSetMqtt);
    on<SaveSerialSetEvent>(_onSaveSerialSet);
  }

  Future<void> _onFetchSerialSet(
    FetchSerialSetEvent event,
    Emitter<SerialSetState> emit,
  ) async {
    emit(SerialSetLoading());
    final result = await repository.getSerialSet(
      userId: event.userId,
      controllerId: event.controllerId,
      subUserId: event.subUserId,
    );
    result.fold(
      (failure) => emit(SerialSetError(failure.message)),
      (success) => emit(SerialSetLoaded(
        userId: event.userId,
        controllerId: event.controllerId,
        subUserId: event.subUserId,
        deviceId: event.deviceId,
        entity: success,
      )),
    );
  }

  void _onUpdateLoraKey(
    UpdateLoraKeyEvent event,
    Emitter<SerialSetState> emit,
  ) {
    final currentState = state;
    if (currentState is! SerialSetLoaded) return;
    emit(currentState.copyWith(
      updatedEntity: currentState.entity.copyWith(loraKey: event.value),
    ));
  }

  Future<void> _onSendSerialSetMqtt(
    SendSerialSetMqttEvent event,
    Emitter<SerialSetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SerialSetLoaded) return;

    Map<String, dynamic> smsFormats = {};
    try {
      smsFormats = jsonDecode(currentState.entity.smsFormat);
    } catch (_) {}

    String command = smsFormats[event.smsKey] ?? event.smsKey;
    
    // Strip '#' prefix if present in the command from API
    if (command.startsWith('#')) {
      command = command.substring(1);
    }
    
    // Use space separator for values (e.g. LORAKEY 123)
    final finalSms = event.extraValue != null ? "$command ${event.extraValue}" : command;

    final result = await repository.sendMqttCommand(
      deviceId: currentState.deviceId,
      command: finalSms,
      userId: currentState.userId,
      controllerId: currentState.controllerId,
      subUserId: currentState.subUserId,
      sentSms: finalSms,
    );

    result.fold(
      (failure) => emit(SerialSetError(failure.message)),
      (_) {
        emit(SerialSetActionSuccess(
          message: event.successMessage,
          entity: currentState.entity,
        ));
        emit(currentState);
      },
    );
  }

  Future<void> _onSaveSerialSet(
    SaveSerialSetEvent event,
    Emitter<SerialSetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SerialSetLoaded) return;

    final result = await repository.saveSerialSet(
      userId: currentState.userId,
      controllerId: currentState.controllerId,
      subUserId: currentState.subUserId,
      entity: currentState.entity,
      sentSms: event.sentSms,
    );

    result.fold(
      (failure) => emit(SerialSetError(failure.message)),
      (_) {
        emit(SerialSetActionSuccess(
          message: "message delivered",
          entity: currentState.entity,
        ));
        emit(currentState);
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/serial_set_repository.dart';
import 'serial_set_event.dart';
import 'serial_set_state.dart';

class SerialSetBloc extends Bloc<SerialSetEvent, SerialSetState> {
  final SerialSetRepository repository;

  SerialSetBloc({required this.repository}) : super(SerialSetInitial()) {
    on<FetchSerialSetEvent>((event, emit) async {
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
    });

    on<UpdateLoraKeyEvent>((event, emit) {
      if (state is! SerialSetLoaded) return;
      final currentState = state as SerialSetLoaded;
      emit(currentState.copyWith(
        updatedEntity: currentState.entity.copyWith(loraKey: event.value),
      ));
    });

    on<SendSerialSetMqttEvent>((event, emit) async {
      if (state is! SerialSetLoaded) return;
      final currentState = state as SerialSetLoaded;
      final entity = currentState.entity;

      // Logic to match senior implementation: Dynamic SMS format from API
      Map<String, dynamic> smsFormats = {};
      try {
        smsFormats = jsonDecode(entity.smsFormat);
      } catch (_) {}

      String command = smsFormats[event.smsKey] ?? event.smsKey;

      // Removed the hardcoded comma to support direct concatenation like #SERIALSET001
      String finalSms = event.extraValue != null ? "$command${event.extraValue}" : command;

      // Special handling for LORA key (C008) to remove '#' if present in the final command
      if (event.smsKey == "C008") {
        finalSms = finalSms.replaceAll("#", "");
      }

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
            (_) => emit(SerialSetActionSuccess(
          message: event.successMessage,
          entity: currentState.entity,
        )),
      );
      emit(currentState);
    });

    on<SaveSerialSetEvent>((event, emit) async {
      if (state is! SerialSetLoaded) return;
      final currentState = state as SerialSetLoaded;

      final result = await repository.saveSerialSet(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        entity: currentState.entity,
        sentSms: event.sentSms,
      );

      result.fold(
            (failure) => emit(SerialSetError(failure.message)),
            (_) => emit(SerialSetActionSuccess(
          message: "message delivered",
          entity: currentState.entity,
        )),
      );
      emit(currentState);
    });
  }
}

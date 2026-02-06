import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/valve_flow_entity.dart';
import '../../domain/repositories/valve_flow_repository.dart';
import 'valve_flow_event.dart';
import 'valve_flow_state.dart';

class ValveFlowBloc extends Bloc<ValveFlowEvent, ValveFlowState> {
  final ValveFlowRepository repository;

  ValveFlowBloc({required this.repository}) : super(ValveFlowInitial()) {
    on<FetchValveFlowDataEvent>((event, emit) async {
      emit(ValveFlowLoading());
      final result = await repository.getValveFlowSetting(
        userId: event.userId,
        controllerId: event.controllerId,
        subUserId: event.subUserId,
      );
      result.fold(
            (failure) => emit(ValveFlowError(message: failure.message)),
            (success) => emit(ValveFlowLoaded(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
          deviceId: event.deviceId,
          entity: success.copyWith(deviceId: event.deviceId),
        )),
      );
    });

    on<UpdateValveFlowNodeEvent>((event, emit) {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final currentEntity = currentState.entity;

      final updatedNodes = List<ValveFlowNodeEntity>.from(currentEntity.nodes);
      updatedNodes[event.index] = updatedNodes[event.index].copyWith(nodeValue: event.nodeValue);

      emit(currentState.copyWith(
        updatedEntity: currentEntity.copyWith(nodes: updatedNodes),
      ));
    });

    on<UpdateCommonFlowDeviationEvent>((event, emit) {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      emit(currentState.copyWith(
        updatedEntity: currentState.entity.copyWith(flowDeviation: event.deviation),
      ));
    });

    on<SendValveFlowSmsEvent>((event, emit) async {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final entity = currentState.entity;

      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);
      final node = entity.nodes[event.index];
      final command = smsFormats['F001'] ?? 'FLOWVALSET';

      final payload = "$command,${node.serialNo},${node.nodeValue}".replaceAll(RegExp(r'\s+'), '');

      if (kDebugMode) {
        print("VALVE FLOW MQTT: Topic: ${currentState.deviceId}, Cmd: $payload");
      }

      final result = await repository.saveValveFlowSettings(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        entity: entity,
        sentSms: payload,
      );

      result.fold(
            (failure) => emit(ValveFlowError(message: failure.message)),
            (_) => emit(ValveFlowSuccess(message: "Valve setting sent successfully", data: entity)),
      );
      emit(currentState);
    });

    on<SaveCommonDeviationEvent>((event, emit) async {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final entity = currentState.entity;

      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);
      final command = smsFormats['F002'] ?? 'FLOWDEV';

      final payload = "$command,${entity.flowDeviation}".replaceAll(RegExp(r'\s+'), '');

      if (kDebugMode) {
        print("VALVE DEVIATION MQTT: Topic: ${currentState.deviceId}, Cmd: $payload");
      }

      final result = await repository.saveValveFlowSettings(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        entity: entity,
        sentSms: payload,
      );

      result.fold(
            (failure) => emit(ValveFlowError(message: failure.message)),
            (_) => emit(ValveFlowSuccess(message: "Deviation sent and saved successfully", data: entity)),
      );
      emit(currentState);
    });

    on<ViewValveFlowEvent>((event, emit) async {
      if (state is! ValveFlowLoaded && state is! ValveFlowSuccess) return;
      final currentState = (state is ValveFlowLoaded)
          ? (state as ValveFlowLoaded)
          : null;

      if (currentState == null) return;

      final entity = currentState.entity;

      try {
        final statusMsg = "#VFLOWSET";

        if (kDebugMode) {
          print("VALVE FLOW VIEW MQTT: Topic: ${currentState.deviceId}, Cmd: $statusMsg");
        }

        await repository.saveValveFlowSettings(
          userId: currentState.userId,
          controllerId: currentState.controllerId,
          subUserId: currentState.subUserId,
          entity: entity,
          sentSms: statusMsg,
        );

        emit(ValveFlowSuccess(message: event.successMessage, data: entity));
        emit(currentState);
      } catch (e) {
        emit(const ValveFlowError(message: "View status failed."));
      }
    });
  }

  Map<String, dynamic> _parseSmsFormat(String raw) {
    if (raw.isEmpty) return {"F001": "FLOWVALSET", "F002": "FLOWDEV"};
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {"F001": "FLOWVALSET", "F002": "FLOWDEV"};
  }
}

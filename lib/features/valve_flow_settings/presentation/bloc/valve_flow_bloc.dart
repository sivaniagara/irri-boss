import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/domain/repositories/valve_flow_repository.dart';
import '../../domain/entities/valve_flow_entity.dart';
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
          entity: success,
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

      final result = await repository.publishValveFlowSms(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        sentSms: payload,
      );

      result.fold(
        (failure) => emit(ValveFlowError(message: failure.message)),
        (_) => emit(ValveFlowSuccess(message: "Valve setting sent successfully", data: entity)),
      );
      // Re-emit loaded state
      emit(currentState);
    });

    on<SaveCommonDeviationEvent>((event, emit) async {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final entity = currentState.entity;
      
      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);
      final command = smsFormats['F002'] ?? 'FLOWDEV';
      final payload = "$command,${entity.flowDeviation}".replaceAll(RegExp(r'\s+'), '');

      // 1. Send SMS (Publish + Log History)
      final smsResult = await repository.publishValveFlowSms(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        sentSms: payload,
      );

      if (smsResult.isRight()) {
        // 2. Save to database
        final saveResult = await repository.saveValveFlowSettings(
          userId: currentState.userId,
          controllerId: currentState.controllerId,
          subUserId: currentState.subUserId,
          entity: entity,
        );

        saveResult.fold(
          (failure) => emit(ValveFlowError(message: failure.message)),
          (_) => emit(ValveFlowSuccess(message: "Deviation sent and saved successfully", data: entity)),
        );
      } else {
        smsResult.fold((f) => emit(ValveFlowError(message: f.message)), (_) {});
      }
      emit(currentState);
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

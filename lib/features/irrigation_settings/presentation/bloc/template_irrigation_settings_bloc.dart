import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/common_setting_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/valve_flow_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/get_valve_flow_setting_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/publish_valve_flow_sms_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/save_valve_flow_settings_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import '../../domain/entities/common_setting_group_entity.dart';
import '../../domain/entities/controller_irrigation_setting_entity.dart';
import '../../domain/usecases/get_template_irrigation_setting_usecase.dart';

part 'template_irrigation_settings_event.dart';
part 'template_irrigation_settings_state.dart';

class TemplateIrrigationSettingsBloc extends Bloc<TemplateIrrigationSettingsEvent, TemplateIrrigationSettingsState> {
  final GetTemplateIrrigationSettingUsecase getTemplateIrrigationSettingUsecase;
  final GetValveFlowSettingUsecase getValveFlowSettingUsecase;
  final PublishValveFlowSmsUsecase publishValveFlowSmsUsecase;
  final SaveValveFlowSettingsUsecase saveValveFlowSettingsUsecase;

  TemplateIrrigationSettingsBloc({
    required this.getTemplateIrrigationSettingUsecase,
    required this.getValveFlowSettingUsecase,
    required this.publishValveFlowSmsUsecase,
    required this.saveValveFlowSettingsUsecase,
  }) : super(TemplateIrrigationSettingsInitial()) {

    on<FetchTemplateSettingEvent>((event, emit) async {
      emit(TemplateIrrigationSettingsLoading());
      GetTemplateIrrigationSettingParams params = GetTemplateIrrigationSettingParams(
        userId: event.userId,
        controllerId: event.controllerId,
        subUserId: event.subUserId,
        settingNo: event.settingNo,
      );

      if (event.settingNo == IrrigationSettingsEnum.valveFlow.settingId.toString()) {
        final result = await getValveFlowSettingUsecase(params);
        result.fold(
          (failure) => emit(TemplateIrrigationSettingsFailure(message: failure.message)),
          (success) => emit(ValveFlowLoaded(
            userId: event.userId,
            controllerId: event.controllerId,
            subUserId: event.subUserId,
            valveFlowEntity: success,
          )),
        );
      } else {
        final result = await getTemplateIrrigationSettingUsecase(params);
        result.fold(
          (failure) => emit(TemplateIrrigationSettingsFailure(message: failure.message)),
          (success) => emit(TemplateIrrigationSettingsLoaded(
            userId: event.userId,
            controllerId: event.controllerId,
            subUserId: event.subUserId,
            settingId: event.settingNo,
            controllerIrrigationSettingEntity: success,
          )),
        );
      }
    });

    on<UpdateSingleSettingRowEvent>((event, emit) {
      if (state is! TemplateIrrigationSettingsLoaded) return;
      final current = state as TemplateIrrigationSettingsLoaded;
      emit(
        current.copyWith(
          updatedControllerIrrigationSettingEntity: current.controllerIrrigationSettingEntity.copyWith(
            updatedSettings: current.controllerIrrigationSettingEntity.settings
                .asMap()
                .entries
                .map((groupEntry) {
              final index = groupEntry.key;
              CommonSettingGroupEntity e = groupEntry.value;
              if (index == event.groupIndex) {
                return e.copyWith(
                  updatedSets: e.sets.asMap().entries.map((settingEntry) {
                    final settingIndex = settingEntry.key;
                    final setting = settingEntry.value;
                    if (settingIndex == event.index && setting is SingleSettingItemEntity) {
                      return setting.copyWith(updateValue: event.value);
                    }
                    return setting;
                  }).toList(),
                );
              }
              return e;
            }).toList(),
          ),
        ),
      );
    });

    on<UpdateMultipleSettingRowEvent>((event, emit) {
      if (state is! TemplateIrrigationSettingsLoaded) return;
      final currentState = state as TemplateIrrigationSettingsLoaded;
      final currentEntity = currentState.controllerIrrigationSettingEntity;

      final newSettings = currentEntity.settings.asMap().entries.map((groupEntry) {
        final groupIndex = groupEntry.key;
        final group = groupEntry.value;

        if (groupIndex != event.groupIndex) {
          return group;
        }

        final newSets = group.sets.asMap().entries.map((setEntry) {
          final setIndex = setEntry.key;
          final setItem = setEntry.value;

          if (setIndex != event.multipleIndex || setItem is! MultipleSettingItemEntity) {
            return setItem;
          }

          final multipleItem = setItem;
          final newSingleItems = multipleItem.listOfSingleSettingItemEntity.asMap().entries.map((singleEntry) {
            final singleIndex = singleEntry.key;
            final singleItem = singleEntry.value;

            if (singleIndex == event.index) {
              return singleItem.copyWith(updateValue: event.value);
            }
            return singleItem;
          }).toList();

          return MultipleSettingItemEntity(listOfSingleSettingItemEntity: newSingleItems);
        }).toList();

        return group.copyWith(updatedSets: newSets);
      }).toList();

      emit(currentState.copyWith(
        updatedControllerIrrigationSettingEntity: currentEntity.copyWith(updatedSettings: newSettings),
      ));
    });

    on<UpdateValveFlowNodeEvent>((event, emit) {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final currentEntity = currentState.valveFlowEntity;

      final updatedNodes = List<ValveFlowNodeEntity>.from(currentEntity.nodes);
      final nodeToUpdate = updatedNodes[event.index];

      updatedNodes[event.index] = nodeToUpdate.copyWith(
        nodeValue: event.nodeValue,
      );

      emit(currentState.copyWith(
        updatedValveFlowEntity: currentEntity.copyWith(nodes: updatedNodes),
      ));
    });

    on<UpdateCommonFlowDeviationEvent>((event, emit) {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      emit(currentState.copyWith(
        updatedValveFlowEntity: currentState.valveFlowEntity.copyWith(flowDeviation: event.deviation),
      ));
    });

    on<SendValveFlowSmsEvent>((event, emit) async {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final entity = currentState.valveFlowEntity;
      
      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);

      if (event.index != null) {
        final node = entity.nodes[event.index!];
        final command = smsFormats['F001'] ?? 'FLOWVALSET';
        
        // Build the payload string strictly without any spaces or formatting issues
        final payload = "$command,${node.serialNo},${node.nodeValue}".replaceAll(RegExp(r'\s+'), '');
        
        final result = await publishValveFlowSmsUsecase(PublishValveFlowSmsParams(
          userId: currentState.userId,
          controllerId: currentState.controllerId,
          subUserId: currentState.subUserId,
          sentSms: payload,
        ));

        result.fold(
          (failure) => emit(TemplateIrrigationSettingsFailure(message: failure.message)),
          (_) {
            emit(SettingUpdateSuccess(message: "Valve settings sent successfully"));
            emit(currentState);
          },
        );
      }
    });

    on<SaveValveFlowSettingsEvent>((event, emit) async {
      if (state is! ValveFlowLoaded) return;
      final currentState = state as ValveFlowLoaded;
      final entity = currentState.valveFlowEntity;
      
      Map<String, dynamic> smsFormats = _parseSmsFormat(entity.smsFormat);

      final command = smsFormats['F002'] ?? 'FLOWDEV';
      // Build the payload string strictly without any spaces
      final payload = "$command,${entity.flowDeviation}".replaceAll(RegExp(r'\s+'), '');
      
      // 1. MQTT + History Log
      final smsResult = await publishValveFlowSmsUsecase(PublishValveFlowSmsParams(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        sentSms: payload,
      ));

      // Use a more robust check for Either results to prevent async gap exceptions
      final bool isSmsSuccess = smsResult.isRight();
      
      if (!isSmsSuccess) {
        smsResult.fold(
          (failure) => emit(TemplateIrrigationSettingsFailure(message: failure.message)),
          (_) {},
        );
        return;
      }

      // 2. Save to DB
      final saveResult = await saveValveFlowSettingsUsecase(SaveValveFlowSettingsParams(
        userId: currentState.userId,
        controllerId: currentState.controllerId,
        subUserId: currentState.subUserId,
        entity: entity,
      ));

      saveResult.fold(
        (failure) => emit(TemplateIrrigationSettingsFailure(message: failure.message)),
        (_) {
          emit(SettingUpdateSuccess(message: "Deviation sent successfully"));
          emit(currentState);
        },
      );
    });
  }

  Map<String, dynamic> _parseSmsFormat(String raw) {
    if (raw.isEmpty) return {"F001": "FLOWVALSET", "F002": "FLOWDEV"};
    try {
      // Handle potential double-encoding or already parsed states
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {"F001": "FLOWVALSET", "F002": "FLOWDEV"};
  }
}

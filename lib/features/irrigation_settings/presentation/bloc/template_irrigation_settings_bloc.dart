import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/common_setting_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/update_template_irrigation_setting_usecase.dart';
import '../../domain/entities/common_setting_group_entity.dart';
import '../../domain/entities/controller_irrigation_setting_entity.dart';
import '../../domain/usecases/get_template_irrigation_setting_usecase.dart';
import '../enums/update_template_setting_status.dart';
part 'template_irrigation_settings_event.dart';
part 'template_irrigation_settings_state.dart';


class TemplateIrrigationSettingsBloc extends Bloc<TemplateIrrigationSettingsEvent, TemplateIrrigationSettingsState>{
  final GetTemplateIrrigationSettingUsecase getTemplateIrrigationSettingUsecase;
  final UpdateTemplateIrrigationSettingUsecase updateTemplateIrrigationSettingUsecase;
  TemplateIrrigationSettingsBloc({
    required this.getTemplateIrrigationSettingUsecase,
    required this.updateTemplateIrrigationSettingUsecase,
  }) : super(TemplateIrrigationSettingsInitial()){

    on<FetchTemplateSettingEvent>((event, emit) async{
      emit(TemplateIrrigationSettingsLoading());
      GetTemplateIrrigationSettingParams params = GetTemplateIrrigationSettingParams(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
          settingNo: event.settingNo
      );

      final result = await getTemplateIrrigationSettingUsecase(params);

      result.fold(
              (failure){
            emit(TemplateIrrigationSettingsFailure(message: failure.message));
          },
              (success){
            emit(
                TemplateIrrigationSettingsLoaded(
                    userId: event.userId,
                    controllerId: event.controllerId,
                    deviceId: event.deviceId,
                    subUserId: event.subUserId,
                    settingId: event.settingNo,
                    controllerIrrigationSettingEntity: success
                )
            );
          }
      );
    });

    on<UpdateSingleSettingRowEvent>((event, emit){
      final current = state as TemplateIrrigationSettingsLoaded;
      emit(
          current.copyWith(
              updatedControllerIrrigationSettingEntity: current.controllerIrrigationSettingEntity.copyWith(
                  updatedSettings: current.controllerIrrigationSettingEntity.settings
                      .asMap()
                      .entries
                      .map((groupEntry){
                    final index = groupEntry.key;
                    CommonSettingGroupEntity e = groupEntry.value;
                    if(index == event.groupIndex){
                      return e.copyWith(
                          updatedSets: e.sets.asMap().entries.map((settingEntry){
                            final settingIndex = settingEntry.key;
                            final setting = settingEntry.value;
                            if(settingIndex == event.index && setting is SingleSettingItemEntity){
                              return setting.copyWith(updateValue: event.value);
                            }
                            return setting;
                          }).toList()
                      );
                    }
                    return e;
                  }).toList()
              ),
              status: UpdateTemplateSettingStatus.idle
          )
      );
    });

    on<UpdateMultipleSettingRowEvent>((event, emit) {
      final currentState = state as TemplateIrrigationSettingsLoaded;
      final currentEntity = currentState.controllerIrrigationSettingEntity;

      final newSettings = currentEntity.settings.asMap().entries.map((groupEntry) {
        final groupIndex = groupEntry.key;
        final group = groupEntry.value;

        if (groupIndex != event.groupIndex) {
          return group; // unchanged group
        }

        // Update this group
        final newSets = group.sets.asMap().entries.map((setEntry) {
          final setIndex = setEntry.key;
          final setItem = setEntry.value;

          if (setIndex != event.multipleIndex || setItem is! MultipleSettingItemEntity) {
            return setItem; // unchanged
          }

          // This is the MultipleSettingItemEntity we want to update
          final multipleItem = setItem;

          final newSingleItems = multipleItem.listOfSingleSettingItemEntity.asMap().entries.map((singleEntry) {
            final singleIndex = singleEntry.key;
            final singleItem = singleEntry.value;

            if (singleIndex == event.index) {
              return singleItem.copyWith(updateValue: event.value);
            }
            return singleItem; // unchanged
          }).toList();

          return MultipleSettingItemEntity(listOfSingleSettingItemEntity: newSingleItems);
        }).toList();

        return group.copyWith(updatedSets: newSets);
      }).toList();

      final newControllerEntity = currentEntity.copyWith(updatedSettings: newSettings);

      emit(currentState.copyWith(
          updatedControllerIrrigationSettingEntity: newControllerEntity,
          status: UpdateTemplateSettingStatus.idle
      ));
    });

    on<UpdateTemplateSettingEvent>((event, emit)async{
      if(state is! TemplateIrrigationSettingsLoaded){
        return;
      }

      final currentState = state as TemplateIrrigationSettingsLoaded;
      emit(currentState.copyWith(updatedControllerIrrigationSettingEntity: currentState.controllerIrrigationSettingEntity, status: UpdateTemplateSettingStatus.loading));
      UpdateTemplateIrrigationSettingParams params = UpdateTemplateIrrigationSettingParams(
          userId: currentState.userId,
          controllerId: currentState.controllerId,
          subUserId: currentState.subUserId,
          settingNo: currentState.settingId,
          controllerIrrigationSettingEntity: currentState.controllerIrrigationSettingEntity,
          groupIndex: event.groupIndex,
          settingIndex: event.settingIndex, deviceId: currentState.deviceId
      );

      final result = await updateTemplateIrrigationSettingUsecase(params);

      result.fold(
              (failure){
            emit(
                currentState
                    .copyWith(
                    updatedControllerIrrigationSettingEntity: currentState.controllerIrrigationSettingEntity,
                    status: UpdateTemplateSettingStatus.failure,
                    msg: failure.message
                )
            );
          },
              (success){
            emit(
                currentState
                    .copyWith(
                    updatedControllerIrrigationSettingEntity: currentState.controllerIrrigationSettingEntity,
                    status: UpdateTemplateSettingStatus.success,
                    msg: 'Setting Updated SuccessFully!'
                )
            );
          }
      );
    });

  }

}
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/common_id_settings/domain/entities/category_entity.dart';

import '../enums/common_id_settings_enum.dart';

abstract class CommonIdSettingsState{}

class CommonIdSettingsInitial extends CommonIdSettingsState{}
class CommonIdSettingsLoading extends CommonIdSettingsState{}

class CommonIdSettingsLoaded extends CommonIdSettingsState {
  final String userId;
  final String controllerId;
  final List<CategoryEntity> listOfCategoryEntity;
  CommonIdSettingsUpdateStatus commonIdSettingsUpdateStatus;

  CommonIdSettingsLoaded({
    required this.userId,
    required this.controllerId,
    required this.listOfCategoryEntity,
    this.commonIdSettingsUpdateStatus = CommonIdSettingsUpdateStatus.idle,
  });

  CommonIdSettingsLoaded copyWith({
    List<CategoryEntity>? listOfCategoryEntity,
    CommonIdSettingsUpdateStatus? status
  }) {
    return CommonIdSettingsLoaded(
      userId: userId,
      controllerId: controllerId,
      listOfCategoryEntity:
      listOfCategoryEntity ?? this.listOfCategoryEntity,
        commonIdSettingsUpdateStatus : status ?? commonIdSettingsUpdateStatus
    );
  }
}



class CommonIdSettingsError extends CommonIdSettingsState{
  final String message;
  CommonIdSettingsError({required this.message});
}
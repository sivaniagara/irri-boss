import 'package:niagara_smart_drip_irrigation/features/common_id_settings/domain/entities/category_entity.dart';

import '../enums/common_id_settings_enum.dart';
import '../enums/reset_common_id_enum.dart';
import '../enums/view_common_id_enum.dart';

abstract class CommonIdSettingsState{}

class CommonIdSettingsInitial extends CommonIdSettingsState{}
class CommonIdSettingsLoading extends CommonIdSettingsState{}

class CommonIdSettingsLoaded extends CommonIdSettingsState {
  final String userId;
  final String controllerId;
  final String deviceId;
  final List<CategoryEntity> listOfCategoryEntity;
  ResetCommonIdEnum resetCommonIdEnum;
  ViewCommonIdEnum viewCommonIdEnum;
  CommonIdSettingsUpdateStatus commonIdSettingsUpdateStatus;

  CommonIdSettingsLoaded({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.listOfCategoryEntity,
    this.commonIdSettingsUpdateStatus = CommonIdSettingsUpdateStatus.idle,
    this.resetCommonIdEnum = ResetCommonIdEnum.idle,
    this.viewCommonIdEnum = ViewCommonIdEnum.idle,
  });

  CommonIdSettingsLoaded copyWith({
    List<CategoryEntity>? listOfCategoryEntity,
    CommonIdSettingsUpdateStatus? status,
    ResetCommonIdEnum? resetCommonIdEnumStatus,
    ViewCommonIdEnum? viewCommonIdEnumStatus,
  }) {
    return CommonIdSettingsLoaded(
      userId: userId,
      controllerId: controllerId,
      deviceId: deviceId,
      listOfCategoryEntity:
      listOfCategoryEntity ?? this.listOfCategoryEntity,
      commonIdSettingsUpdateStatus : status ?? commonIdSettingsUpdateStatus,
      resetCommonIdEnum : resetCommonIdEnumStatus ?? resetCommonIdEnum,
      viewCommonIdEnum : viewCommonIdEnumStatus ?? viewCommonIdEnum,
    );
  }
}

class CommonIdSettingsError extends CommonIdSettingsState{
  final String message;
  CommonIdSettingsError({required this.message});
}
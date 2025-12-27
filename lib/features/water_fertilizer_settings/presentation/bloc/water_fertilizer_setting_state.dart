part of 'water_fertilizer_setting_bloc.dart';


abstract class WaterFertilizerSettingState{}

class WaterFertilizerSettingInitial extends WaterFertilizerSettingState{}
class WaterFertilizerSettingLoading extends WaterFertilizerSettingState{}
class WaterFertilizerSettingLoaded extends WaterFertilizerSettingState{
  final String userId;
  final String controllerId;
  final String subUserId;
  final ProgramZoneSetEntity programZoneSetEntity;
  WaterFertilizerSettingLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programZoneSetEntity,
  });
}
class WaterFertilizerSettingFailure extends WaterFertilizerSettingState{}



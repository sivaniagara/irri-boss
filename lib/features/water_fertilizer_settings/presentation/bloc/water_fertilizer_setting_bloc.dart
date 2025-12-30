import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/program_zone_set_entity.dart';
import '../../domain/usecases/fetch_program_zone_sets_usecase.dart';
import '../../domain/usecases/fetch_zone_set_setting_usecase.dart';
part 'water_fertilizer_setting_event.dart';
part 'water_fertilizer_setting_state.dart';

class WaterFertilizerSettingBloc extends Bloc<WaterFertilizerSettingEvent, WaterFertilizerSettingState>{
  final FetchProgramZoneSetsUsecase fetchProgramZoneSetsUsecase;
  final FetchZoneSetSettingUsecase fetchZoneSetSettingUsecase;
  WaterFertilizerSettingBloc({
    required this.fetchProgramZoneSetsUsecase,
    required this.fetchZoneSetSettingUsecase,
  }) : super(WaterFertilizerSettingInitial()){

    on<FetchProgramZoneSetEvent>((event, emit)async{
      emit(WaterFertilizerSettingLoading());
      FetchProgramZoneSetsParams fetchProgramZoneSetsParams = FetchProgramZoneSetsParams(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
          programId: event.programId
      );

      final result = await fetchProgramZoneSetsUsecase(fetchProgramZoneSetsParams);

      result
          .fold(
              (failure){
                emit(WaterFertilizerSettingFailure());
              },
              (success){
                emit(WaterFertilizerSettingLoaded(
                    userId: event.userId,
                    controllerId: event.controllerId,
                    subUserId: event.subUserId,
                    programZoneSetEntity: success
                ));
              }
      );

    });

    on<FetchZoneSetSettingEvent>((event, emit)async{
      emit(WaterFertilizerSettingLoading());
      FetchZoneSetSettingParams fetchZoneSetSettingParams = FetchZoneSetSettingParams(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
        programSettingNo: event.programSettingNo,
        zoneSetId: event.zoneSetId,
      );

      final result = await fetchZoneSetSettingUsecase(fetchZoneSetSettingParams);

      result
          .fold(
              (failure){
            emit(WaterFertilizerSettingFailure());
          },
              (success){
            emit(WaterFertilizerSettingLoaded(
                userId: event.userId,
                controllerId: event.controllerId,
                subUserId: event.subUserId,
                programZoneSetEntity: success
            ));
          }
      );

    });
  }
}
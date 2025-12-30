import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/usecases/update_zone_set_setting_usecase.dart';

import '../../domain/entities/program_zone_set_entity.dart';
import '../../domain/usecases/fetch_program_zone_sets_usecase.dart';
import '../../domain/usecases/fetch_zone_set_setting_usecase.dart';
import '../enums/zone_set_update_status_enum.dart';
part 'water_fertilizer_setting_event.dart';
part 'water_fertilizer_setting_state.dart';

class WaterFertilizerSettingBloc extends Bloc<WaterFertilizerSettingEvent, WaterFertilizerSettingState>{
  final FetchProgramZoneSetsUsecase fetchProgramZoneSetsUsecase;
  final FetchZoneSetSettingUsecase fetchZoneSetSettingUsecase;
  final UpdateZoneSetSettingUsecase updateZoneSetSettingUsecase;
  WaterFertilizerSettingBloc({
    required this.fetchProgramZoneSetsUsecase,
    required this.fetchZoneSetSettingUsecase,
    required this.updateZoneSetSettingUsecase,
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
      print('state => ${state}');
      print("FetchZoneSetSettingEvent called....");
      emit(WaterFertilizerSettingLoading());
      FetchZoneSetSettingParams fetchZoneSetSettingParams = FetchZoneSetSettingParams(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
        programSettingNo: event.programSettingNo,
        zoneSetId: event.zoneSetId,
        programId: event.programId
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
                zoneSetId: event.zoneSetId,
                programZoneSetEntity: success
            ));
          }
      );

    });

    on<UpdateZoneSetSettingEvent>((event, emit)async{
      if(state is! WaterFertilizerSettingLoaded){
        return;
      }
      final current = state as WaterFertilizerSettingLoaded;
      emit(current.copyWith(updatedZoneSetUpdateStatusEnum: ZoneSetUpdateStatusEnum.loading));
      UpdateZoneSetSettingParams updateZoneSetSettingParams = UpdateZoneSetSettingParams(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programId: current.programZoneSetEntity.programId,
          programSettingNo: current.programSettingNo!,
          zoneSetId: current.zoneSetId!,
          channelNo: event.channelNo,
          irrigationDosingOrPrePost: event.irrigationDosingOrPrePost,
          mode: event.mode,
          method: event.method,
          programZoneSetEntity: current.programZoneSetEntity
      );

      final result = await updateZoneSetSettingUsecase(updateZoneSetSettingParams);

      result
          .fold(
              (failure){
            emit(current.copyWith(updatedZoneSetUpdateStatusEnum: ZoneSetUpdateStatusEnum.failure));
          },
              (success){
                emit(current.copyWith(updatedZoneSetUpdateStatusEnum: ZoneSetUpdateStatusEnum.success));
              }
      );

    });

    on<UpdateTotalTime>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;

      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index].copyWith(updatedTime: event.time);
                      }
                    })
                )
              ]
          )
      ));
    });

    on<UpdateTotalLiters>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;

      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index].copyWith(updatedLiters: event.liters);
                      }
                    })
                )
              ]
          )
      ));
    });

    on<UpdatePreTime>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;

      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index].copyWith(updatedPreTime: event.time);
                      }
                    })
                )
              ]
          )
      ));
    });

    on<UpdatePreLiters>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;

      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index].copyWith(updatedPreLiters: event.liters);
                      }
                    })
                )
              ]
          )
      ));
    });

    on<UpdatePostTime>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;

      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index].copyWith(updatedPostTime: event.time);
                      }
                    })
                )
              ]
          )
      ));
    });

    on<UpdatePostLiters>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;

      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index].copyWith(updatedPostLiters: event.liters);
                      }
                    })
                )
              ]
          )
      ));
    });

    on<UpdateChannelTime>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;

      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index]
                            .copyWith(
                            updatedCh1Time: event.channelIndex == 0 ? event.time : null,
                            updatedCh2Time: event.channelIndex == 1 ? event.time : null,
                            updatedCh3Time: event.channelIndex == 2 ? event.time : null,
                            updatedCh4Time: event.channelIndex == 3 ? event.time : null,
                            updatedCh5Time: event.channelIndex == 4 ? event.time : null,
                            updatedCh6Time: event.channelIndex == 5 ? event.time : null,
                        );
                      }
                    })
                )
              ]
          )
      ));
    });

    on<UpdateChannelLiters>((event, emit){
      final current = state as WaterFertilizerSettingLoaded;
      print("UpdateChannelLiters called");
      print("${event.liters} , ${event.channelIndex}, ${event.zoneNo}");
      emit(WaterFertilizerSettingLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          programZoneSetEntity: current.programZoneSetEntity.copyWith(
              upDatedListOfZoneSet: [
                current.programZoneSetEntity.listOfZoneSet.first.copyWith(
                    updatedListOfZoneWaterFertilizer: List.generate(6, (index){
                      if(index != event.zoneNo){
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index];
                      }else{
                        print("update success");
                        return current.programZoneSetEntity.listOfZoneSet.first.listOfZoneWaterFertilizer[index]
                            .copyWith(
                          updatedCh1Liters: event.channelIndex == 0 ? event.liters : null,
                          updatedCh2Liters: event.channelIndex == 1 ? event.liters : null,
                          updatedCh3Liters: event.channelIndex == 2 ? event.liters : null,
                          updatedCh4Liters: event.channelIndex == 3 ? event.liters : null,
                          updatedCh5Liters: event.channelIndex == 4 ? event.liters : null,
                          updatedCh6Liters: event.channelIndex == 5 ? event.liters : null,
                        );
                      }
                    })
                )
              ]
          )
      ));
    });

  }
}
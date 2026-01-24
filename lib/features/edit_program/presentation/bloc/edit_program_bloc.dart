import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/selected_node_entity.dart';

import '../../../program_settings/sub_module/edit_zone/domain/entities/node_entity.dart';
import '../../domain/entities/edit_program_entity.dart';
import '../../domain/entities/zone_setting_entity.dart';
import '../../domain/usecases/get_program_usecase.dart';
import '../../domain/usecases/save_program_usecase.dart';
import '../../domain/usecases/send_zone_configuration_payload_usecase.dart';
import '../../domain/usecases/send_zone_set_payload_usecase.dart';
import '../enums/add_remove_enum.dart';
import '../pages/payload_page.dart';
part 'edit_program_event.dart';
part 'edit_program_state.dart';

class EditProgramBloc extends Bloc<EditProgramEvent, EditProgramState>{
  final GetProgramUsecase getProgramUsecase;
  final SaveProgramUsecase saveProgramUsecase;
  final SendZoneConfigurationPayloadUsecase sendZoneConfigurationPayloadUsecase;
  final SendZoneSetPayloadUsecase sendZoneSetPayloadUsecase;
  EditProgramBloc({
    required this.getProgramUsecase,
    required this.saveProgramUsecase,
    required this.sendZoneConfigurationPayloadUsecase,
    required this.sendZoneSetPayloadUsecase,
  }) : super(EditProgramInitial()){

    on<GetProgramEvent>((event, emit) async{
      emit(EditProgramLoading());

      GetProgramParams params = GetProgramParams(
          userId: event.userId,
          controllerId: event.controllerId,
          subUserId: event.subUserId,
          programId: event.programId
      );
      final result = await getProgramUsecase(params);

      result.fold(
              (failure){
                emit(EditProgramFailure());
              },
              (success){
                emit(EditProgramLoaded(
                    userId: event.userId,
                    controllerId: event.controllerId,
                    subUserId: event.subUserId,
                    editProgramEntity: success, deviceId: event.deviceId
                ));
              }
      );
    });

    on<SaveProgramEvent>((event, emit) async{
      final current = state as EditProgramLoaded;

      emit(current.copyWith(updatedSaveProgramStatus: SaveProgramStatus.loading));

      SaveProgramParams params = SaveProgramParams(
          userId: event.userId,
          controllerId: event.controllerId,
          deviceId: event.deviceId,
          editProgramEntity: event.editProgramEntity,
      );
      final result = await saveProgramUsecase(params);

      result.fold(
              (failure){
                emit(current.copyWith(updatedSaveProgramStatus: SaveProgramStatus.failure));
          },
              (success){
                emit(current.copyWith(updatedSaveProgramStatus: SaveProgramStatus.success));
                emit(current.copyWith(updatedSaveProgramStatus: SaveProgramStatus.idle));
              }
      );
    });

    on<AddZoneEvent>((event, emit){
      final current = state as EditProgramLoaded;
      late List<ZoneSettingEntity> zonesToUpdate;
      bool inActiveToActive = false;
      if(current.editProgramEntity.zones.any((e) => e.active == false)){
        zonesToUpdate = current.editProgramEntity.zones.map((e){
          if(inActiveToActive == false && e.active == false){
            inActiveToActive = true;
            return ZoneSettingEntity.defaultZone(e.zoneNumber);
          }else{
            return e;
          }
        }).toList();
      }else{
        zonesToUpdate = [
          ...current.editProgramEntity.zones,
          ZoneSettingEntity.defaultZone((current.editProgramEntity.zones.length + 1).toString().padLeft(3, '0'))
        ];
      }

      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity
              .copyWith(updatedZones: zonesToUpdate)
      ));
    });

    on<DeleteZoneEvent>((event, emit){
      final current = state as EditProgramLoaded;
      var zonesToUpdate = List.generate(current.editProgramEntity.zones.length, (index){
        if(event.zoneIndex == index){
          return current.editProgramEntity.zones[index].copyWith(
              isActive: false,
          );
        }else{
          return current.editProgramEntity.zones[index];
        }
      });
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity
              .copyWith(updatedZones: zonesToUpdate)
      ));
    });

    on<AddOrRemoveValveToZoneEvent>((event, emit){
      final current = state as EditProgramLoaded;
      late List<SelectedNodeEntity> updatedList;
      if(event.addRemoveEnum == AddRemoveEnum.add){
        updatedList = [
          ...current.editProgramEntity.zones[event.zoneIndex].valves,
          SelectedNodeEntity(
              nodeId: current.editProgramEntity.mappedValves[event.nodeIndex].nodeId,
              serialNo: current.editProgramEntity.mappedValves[event.nodeIndex].serialNo,
              qrCode: current.editProgramEntity.mappedValves[event.nodeIndex].qrCode
          )
        ];
      }else{
        updatedList = current.editProgramEntity.zones[event.zoneIndex].valves.where((e)=> e.nodeId != current.editProgramEntity.mappedValves[event.nodeIndex].nodeId).toList();
      }
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity
              .copyWith(
              updatedZones: List.generate(
                  current.editProgramEntity.zones.length,
                  (index){
                    if(event.zoneIndex == index){
                      return current.editProgramEntity.zones[index]
                          .copyWith(
                          updatedValves: updatedList
                      );
                    }else{
                      return current.editProgramEntity.zones[index];
                    }
                  }
              )
          )
      ));
    });

    on<AddOrRemoveMoistureToZoneEvent>((event, emit){
      final current = state as EditProgramLoaded;
      late List<SelectedNodeEntity> updatedList;
      if(event.addRemoveEnum == AddRemoveEnum.add){
        updatedList = [
          ...current.editProgramEntity.zones[event.zoneIndex].moistureSensors,
          SelectedNodeEntity(
              nodeId: current.editProgramEntity.mappedMoistureSensors[event.nodeIndex].nodeId,
              serialNo: current.editProgramEntity.mappedMoistureSensors[event.nodeIndex].serialNo,
              qrCode: current.editProgramEntity.mappedMoistureSensors[event.nodeIndex].qrCode
          )
        ];
      }else{
        updatedList = current.editProgramEntity.zones[event.zoneIndex].moistureSensors.where((e)=> e.nodeId != current.editProgramEntity.mappedMoistureSensors[event.nodeIndex].nodeId).toList();
      }
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity
              .copyWith(
              updatedZones: List.generate(
                  current.editProgramEntity.zones.length,
                      (index){
                    if(event.zoneIndex == index){
                      return current.editProgramEntity.zones[index]
                          .copyWith(
                          updatedMoistureSensors: updatedList
                      );
                    }else{
                      return current.editProgramEntity.zones[index];
                    }
                  }
              )
          )
      ));
    });

    on<AddOrRemoveLevelToZoneEvent>((event, emit){
      final current = state as EditProgramLoaded;
      late List<SelectedNodeEntity> updatedList;
      if(event.addRemoveEnum == AddRemoveEnum.add){
        updatedList = [
          ...current.editProgramEntity.zones[event.zoneIndex].levelSensors,
          SelectedNodeEntity(
              nodeId: current.editProgramEntity.mappedLevelSensors[event.nodeIndex].nodeId,
              serialNo: current.editProgramEntity.mappedLevelSensors[event.nodeIndex].serialNo,
              qrCode: current.editProgramEntity.mappedLevelSensors[event.nodeIndex].qrCode
          )
        ];
      }else{
        updatedList = current.editProgramEntity.zones[event.zoneIndex].levelSensors.where((e)=> e.nodeId != current.editProgramEntity.mappedLevelSensors[event.nodeIndex].nodeId).toList();
      }
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity
              .copyWith(
              updatedZones: List.generate(
                  current.editProgramEntity.zones.length,
                      (index){
                    if(event.zoneIndex == index){
                      return current.editProgramEntity.zones[index]
                          .copyWith(
                          updatedLevelSensors: updatedList
                      );
                    }else{
                      return current.editProgramEntity.zones[index];
                    }
                  }
              )
          )
      ));
    });


    on<UpdateTimerAdjustPercent>((event, emit){
      final current = state as EditProgramLoaded;
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity.copyWith(updatedTimerAdjustPercent: event.value)
      ));
    });

    on<UpdateFlowAdjustPercent>((event, emit){
      final current = state as EditProgramLoaded;
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity.copyWith(updatedFlowAdjustPercent: event.value)
      ));
    });

    on<UpdateMoistureAdjustPercent>((event, emit){
      final current = state as EditProgramLoaded;
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity.copyWith(updatedMoistureAdjustPercent: event.value)
      ));
    });

    on<UpdateFertilizerAdjustPercent>((event, emit){
      final current = state as EditProgramLoaded;
      emit(current.copyWith(
          updatedEditProgramEntity: current.editProgramEntity.copyWith(updatedFertilizerAdjustPercent: event.value)
      ));
    });

    on<UpdateTotalTime>((event, emit){
      print("zone Index => ${event.zoneIndex}");
      final current = state as EditProgramLoaded;

      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
            updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
              if(index == event.zoneIndex){
                return current.editProgramEntity.zones[index].copyWith(updatedTime: event.time);
              }else{
                return current.editProgramEntity.zones[index];
              }
            })
          )
      ));
    });

    on<UpdateTotalLiters>((event, emit){
      final current = state as EditProgramLoaded;

      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
              updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
                if(index == event.zoneIndex){
                  return current.editProgramEntity.zones[index].copyWith(updatedLiters: event.liters);
                }else{
                  return current.editProgramEntity.zones[index];
                }
              })
          )
      ));
    });

    on<UpdatePreTime>((event, emit){
      final current = state as EditProgramLoaded;

      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
              updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
                if(index == event.zoneIndex){
                  return current.editProgramEntity.zones[index].copyWith(updatedPreTime: event.time);
                }else{
                  return current.editProgramEntity.zones[index];
                }
              })
          )
      ));
    });

    on<UpdatePreLiters>((event, emit){
      final current = state as EditProgramLoaded;

      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
              updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
                if(index == event.zoneIndex){
                  return current.editProgramEntity.zones[index].copyWith(updatedPreLiters: event.liters);
                }else{
                  return current.editProgramEntity.zones[index];
                }
              })
          )
      ));
    });

    on<UpdatePostTime>((event, emit){
      final current = state as EditProgramLoaded;

      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
              updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
                if(index == event.zoneIndex){
                  return current.editProgramEntity.zones[index].copyWith(updatedPostTime: event.time);
                }else{
                  return current.editProgramEntity.zones[index];
                }
              })
          )
      ));
    });

    on<UpdatePostLiters>((event, emit){
      final current = state as EditProgramLoaded;

      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
              updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
                if(index == event.zoneIndex){
                  return current.editProgramEntity.zones[index].copyWith(updatedPostLiters: event.liters);
                }else{
                  return current.editProgramEntity.zones[index];
                }
              })
          )
      ));
    });

    on<UpdateChannelTime>((event, emit){
      final current = state as EditProgramLoaded;

      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
              updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
                if(index == event.zoneIndex){
                  return current.editProgramEntity.zones[index].copyWith(
                    updatedCh1Time: event.channelIndex == 0 ? event.time : null,
                    updatedCh2Time: event.channelIndex == 1 ? event.time : null,
                    updatedCh3Time: event.channelIndex == 2 ? event.time : null,
                    updatedCh4Time: event.channelIndex == 3 ? event.time : null,
                    updatedCh5Time: event.channelIndex == 4 ? event.time : null,
                    updatedCh6Time: event.channelIndex == 5 ? event.time : null,
                  );
                }else{
                  return current.editProgramEntity.zones[index];
                }
              })
          )
      ));
    });

    on<UpdateChannelLiters>((event, emit){
      print('Channel => ${event.channelIndex}');
      final current = state as EditProgramLoaded;
      emit(EditProgramLoaded(
          userId: current.userId,
          controllerId: current.controllerId,
          subUserId: current.subUserId,
          deviceId: current.deviceId,
          editProgramEntity: current.editProgramEntity.copyWith(
              updatedZones: List.generate(current.editProgramEntity.zones.length, (index){
                if(index == event.zoneIndex){
                  return current.editProgramEntity.zones[index].copyWith(
                    updatedCh1Liters: event.channelIndex == 0 ? event.liters : null,
                    updatedCh2Liters: event.channelIndex == 1 ? event.liters : null,
                    updatedCh3Liters: event.channelIndex == 2 ? event.liters : null,
                    updatedCh4Liters: event.channelIndex == 3 ? event.liters : null,
                    updatedCh5Liters: event.channelIndex == 4 ? event.liters : null,
                    updatedCh6Liters: event.channelIndex == 5 ? event.liters : null,
                  );
                }else{
                  return current.editProgramEntity.zones[index];
                }
              })
          )
      ));
    });
  }

  Future<PayloadModeEnum> sendZonePayload({
    required int zoneIndex,
  }) async {
    final current = state as EditProgramLoaded;

    SendZoneConfigurationParams params = SendZoneConfigurationParams(
      userId: current.userId,
      controllerId: current.controllerId,
      deviceId: current.deviceId,
      programId: current.editProgramEntity.programId,
      zoneSettingEntity: current.editProgramEntity.zones[zoneIndex],
    );

    final result = await sendZoneConfigurationPayloadUsecase(params);

    return result.fold(
          (failure) => PayloadModeEnum.failure,
          (success) => PayloadModeEnum.success,
    );
  }

  Future<PayloadModeEnum> sendZoneSetPayload({
    required int zoneSetNo,
    required int channelNo,
    required int irrigationDosingOrPrePost,
    required int method,
  }) async {
    final current = state as EditProgramLoaded;

    SendZoneSetPayloadParams params = SendZoneSetPayloadParams(
        userId : current.userId,
        controllerId : current.controllerId,
        deviceId : current.deviceId,
        programId : current.editProgramEntity.programId,
        zoneSetNo : zoneSetNo,
        editProgramEntity : current.editProgramEntity,
        channelNo : channelNo,
        irrigationDosingOrPrePost : irrigationDosingOrPrePost,
        method : method,
    );

    final result = await sendZoneSetPayloadUsecase(params);

    return result.fold(
          (failure) => PayloadModeEnum.failure,
          (success) => PayloadModeEnum.success,
    );
  }
}
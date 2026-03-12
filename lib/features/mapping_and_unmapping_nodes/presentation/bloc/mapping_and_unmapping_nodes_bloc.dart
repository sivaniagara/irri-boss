import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_node_entity.dart';
import '../../domain/entities/mapped_node_entity.dart';
import '../../domain/entities/mapping_and_unmapping_node_entity.dart';
import '../../domain/usecases/delete_mapped_node_usecase.dart';
import '../../domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';
import '../../domain/usecases/resend_mapped_node_usecase.dart';
import '../../domain/usecases/unmapped_node_to_mapped_node_usecase.dart';
import '../../domain/usecases/view_node_details_mqtt_usecase.dart';
import '../enums/delete_mapped_node_enum.dart';
import '../enums/resend_command_enum.dart';
import '../enums/unmapped_node_to_mapped_enum.dart';
import '../enums/view_command_enum.dart';
part 'mapping_and_unmapping_nodes_event.dart';
part 'mapping_and_unmapping_nodes_state.dart';

class MappingAndUnmappingNodesBloc extends Bloc<MappingAndUnmappingNodesEvent, MappingAndUnmappingNodesState>{
  final FetchMappingUnmappingNodesUsecase fetchMappingUnmappingNodesUsecase;
  final DeleteMappedNodeUsecase deleteMappedNodeUsecase;
  final UnmappedNodeToMappedNodeUsecase unmappedNodeToMappedNodeUsecase;
  final ViewNodeDetailsMqttUsecase viewNodeDetailsMqttUsecase;
  final ResendMappedNodeUsecase resendMappedNodeUsecase;

  MappingAndUnmappingNodesBloc({
    required this.fetchMappingUnmappingNodesUsecase,
    required this.deleteMappedNodeUsecase,
    required this.unmappedNodeToMappedNodeUsecase,
    required this.viewNodeDetailsMqttUsecase,
    required this.resendMappedNodeUsecase,
  }) : super(MappingAndUnmappingNodesInitial()){

    on<FetchMappingAndUnmappingEvent>((event, emit)async{
      emit(MappingAndUnmappingNodesLoading());
      FetchMappingUnmappingParams fetchMappingUnmappingParams = FetchMappingUnmappingParams(userId: event.userId, controllerId: event.controllerId);
      final result = await fetchMappingUnmappingNodesUsecase(fetchMappingUnmappingParams);
      result
          .fold(
              (failure){
            emit(MappingAndUnmappingNodesError());
          },
              (success){
            emit(
                MappingAndUnmappingNodesLoaded(
                    userId: event.userId,
                    controllerId: event.controllerId,
                    mappingAndUnmappingNodeEntity: success,
                    deviceId: event.deviceId
                )
            );
          }
      );
    });

    on<RefreshMappingAndUnmappingEvent>((event, emit)async{
      FetchMappingUnmappingParams fetchMappingUnmappingParams = FetchMappingUnmappingParams(userId: event.userId, controllerId: event.controllerId);
      final result = await fetchMappingUnmappingNodesUsecase(fetchMappingUnmappingParams);
      result
          .fold(
              (failure){
            emit(MappingAndUnmappingNodesError());
          },
              (success){
            emit(
                MappingAndUnmappingNodesLoaded(
                    userId: event.userId,
                    controllerId: event.controllerId,
                    mappingAndUnmappingNodeEntity: success,
                    deviceId: event.deviceId
                )
            );
          }
      );
    });

    on<DeleteMappedNodeEvent>((event, emit) async {
      if (state is! MappingAndUnmappingNodesLoaded) return;
      final currentState = state as MappingAndUnmappingNodesLoaded;

      emit(currentState.copyWith(deleteStatus: DeleteMappedNodeEnum.loading));

      final params = DeleteMappedNodeParams(
        userId: event.userId,
        controllerId: event.controllerId,
        deviceId: event.deviceId,
        mappedNodeEntity: event.mappedNodeEntity,
      );

      final result = await deleteMappedNodeUsecase(params);

      result.fold(
            (failure) {
          debugPrint("Delete failed: ${failure.message}");
          emit(currentState.copyWith(
            deleteStatus: DeleteMappedNodeEnum.failure,
            msg: failure.message,
          ));
          emit(currentState.copyWith(
            deleteStatus: DeleteMappedNodeEnum.idle,
          ));
        },
            (success) {
          emit(currentState.copyWith(
            deleteStatus: DeleteMappedNodeEnum.success,
          ));
          emit(currentState.copyWith(
            deleteStatus: DeleteMappedNodeEnum.idle,
          ));
          add(
              RefreshMappingAndUnmappingEvent(
                  userId: event.userId,
                  controllerId: event.controllerId,
                  deviceId: event.deviceId
              )
          );
        },
      );
    });

    on<UnMappedNodeToMappedEvent>((event, emit)async{
      final currentState = state as MappingAndUnmappingNodesLoaded;
      emit(currentState.copyWith(unMapToMapStatus: UnmappedNodeToMappedEnum.loading));
      List<UnmappedCategoryNodeEntity> nodeToBeMapped = event.unmappedCategoryEntity.nodes.where((e) => e.select).toList();
      UnmappedNodeToMappedNodeParams unmappedNodeToMappedNodeParams = UnmappedNodeToMappedNodeParams(
          userId: event.userId,
          controllerId: event.controllerId,
          deviceId: currentState.deviceId,
          categoryId: event.categoryId.toString(),
          listOfMappedNodeEntity: currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity,
          listOfUnmappedCategoryNodeEntity: nodeToBeMapped
      );
      final result = await unmappedNodeToMappedNodeUsecase(unmappedNodeToMappedNodeParams);
      result.fold(
              (failure){
            print("failure.message : ${failure.message}");
            emit(currentState.copyWith(unMapToMapStatus: UnmappedNodeToMappedEnum.failure, msg: failure.message));
          },
              (success){
            MappingAndUnmappingNodeEntity mappingAndUnmappingNodeEntity = MappingAndUnmappingNodeEntity(
                listOfMappedNodeEntity: currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity,
                listOfUnmappedCategoryEntity: currentState.mappingAndUnmappingNodeEntity
                    .listOfUnmappedCategoryEntity
                    .map((e){
                  if(e.categoryId != event.categoryId){
                    return e;
                  }else{
                    return UnmappedCategoryEntity(
                        categoryId: event.unmappedCategoryEntity.categoryId,
                        categoryName: event.unmappedCategoryEntity.categoryName,
                        count: event.unmappedCategoryEntity.count,
                        nodes: e.nodes.where((node) => !nodeToBeMapped.any((mappedNode) => mappedNode.nodeId == node.nodeId)).toList()
                    );
                  }
                }).toList()
            );
            emit(
                currentState.copyWith(
                    entity: mappingAndUnmappingNodeEntity,
                    unMapToMapStatus: UnmappedNodeToMappedEnum.success
                )
            );
          }
      );
    });

    on<ViewNodeDetailsMqttEvent>((event, emit) async {
      if (state is MappingAndUnmappingNodesLoaded) {
        final currentState = state as MappingAndUnmappingNodesLoaded;
        emit(currentState.copyWith(viewCommandEnum: ViewCommandEnum.loading));
        final result = await viewNodeDetailsMqttUsecase(
            ViewNodeDetailsMqttParams(
              deviceId: currentState.deviceId,
              mappedNodeEntity: event.mappedNodeEntity,
              userId: currentState.userId,
              controllerId: currentState.controllerId,
            )
        );
        result.fold(
                (failure){
              emit(currentState.copyWith(viewCommandEnum: ViewCommandEnum.failure));
              emit(currentState.copyWith(viewCommandEnum: ViewCommandEnum.idle));
            },
                (success){
              emit(currentState.copyWith(viewCommandEnum: ViewCommandEnum.success));
              emit(currentState.copyWith(viewCommandEnum: ViewCommandEnum.idle));
            }
        );
      }
    });

    on<ResendNodeDetailsMqttEvent>((event, emit) async {
      if (state is MappingAndUnmappingNodesLoaded) {
        final currentState = state as MappingAndUnmappingNodesLoaded;
        emit(currentState.copyWith(resendCommandEnum: ResendCommandEnum.loading));
        final result = await resendMappedNodeUsecase(
            ResendMappedNodeParams(
              deviceId: currentState.deviceId,
              mappedNodeEntity: event.mappedNodeEntity,
              userId: currentState.userId,
              controllerId: currentState.controllerId,
            )
        );
        result.fold(
                (failure){
              emit(currentState.copyWith(resendCommandEnum: ResendCommandEnum.failure));
              emit(currentState.copyWith(resendCommandEnum: ResendCommandEnum.idle));
            },
                (success){
              emit(currentState.copyWith(resendCommandEnum: ResendCommandEnum.success));
              emit(currentState.copyWith(resendCommandEnum: ResendCommandEnum.idle));
            }
        );
      }
    });

    on<ResendMultipleNodeDetailsMqttEvent>((event, emit) async {
      if (state is MappingAndUnmappingNodesLoaded) {
        final currentState = state as MappingAndUnmappingNodesLoaded;

        // Reset all nodes status to idle before starting (optional but clean)
        List<MappedNodeEntity> currentMappedNodes = currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity
            .map((n) => n.copyWidth(status: ResendCommandEnum.idle)).toList();

        for (var nodeToResend in event.mappedNodeEntities) {
          // 1. Set specific node to loading
          currentMappedNodes = currentMappedNodes.map((n) {
            if (n.nodeId == nodeToResend.nodeId) {
              return n.copyWidth(status: ResendCommandEnum.resendLoading);
            }
            return n;
          }).toList();

          emit(currentState.copyWith(
              entity: currentState.mappingAndUnmappingNodeEntity.copyWith(listOfMapped: currentMappedNodes),
              resendCommandEnum: ResendCommandEnum.idle // KEEP global command idle to prevent global alert
          ));

          // 2. Execute usecase
          final result = await resendMappedNodeUsecase(
              ResendMappedNodeParams(
                deviceId: currentState.deviceId,
                mappedNodeEntity: nodeToResend,
                userId: currentState.userId,
                controllerId: currentState.controllerId,
              )
          );
          await Future.delayed(const Duration(seconds: 5));

          // 3. Update specific node with result
          currentMappedNodes = currentMappedNodes.map((n) {
            if (n.nodeId == nodeToResend.nodeId) {
              return result.fold(
                      (failure) => n.copyWidth(status: ResendCommandEnum.failure),
                      (success) => n.copyWidth(status: ResendCommandEnum.success)
              );
            }
            return n;
          }).toList();

          emit(currentState.copyWith(
              entity: currentState.mappingAndUnmappingNodeEntity.copyWith(listOfMapped: currentMappedNodes),
              resendCommandEnum: ResendCommandEnum.idle
          ));
        }
      }
    });

    on<UpdateResendStatusToIdle>((event, emit){
      final currentState = state as MappingAndUnmappingNodesLoaded;
      List<MappedNodeEntity> defaultMappedNodes = currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity
          .map((n) => n.copyWidth(status: ResendCommandEnum.idle, isSelect: false)).toList();
      emit(currentState.copyWith(
          entity: currentState.mappingAndUnmappingNodeEntity.copyWith(listOfMapped: defaultMappedNodes),
          resendCommandEnum: ResendCommandEnum.idle
      ));
    });
  }
}
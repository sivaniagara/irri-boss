import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_node_entity.dart';

import '../../../common_id_settings/data/models/category_model.dart';
import '../../domain/entities/mapped_node_entity.dart';
import '../../domain/entities/mapping_and_unmapping_node_entity.dart';
import '../../domain/entities/unmapped_category_node_entity.dart';
import '../../domain/usecases/delete_mapped_node_usecase.dart';
import '../../domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';
import '../../domain/usecases/unmapped_node_to_mapped_node_usecase.dart';
import '../../domain/usecases/view_node_details_mqtt_usecase.dart';
import '../enums/delete_mapped_node_enum.dart';
import '../enums/unmapped_node_to_mapped_enum.dart';
part 'mapping_and_unmapping_nodes_event.dart';
part 'mapping_and_unmapping_nodes_state.dart';

class MappingAndUnmappingNodesBloc extends Bloc<MappingAndUnmappingNodesEvent, MappingAndUnmappingNodesState>{
  final FetchMappingUnmappingNodesUsecase fetchMappingUnmappingNodesUsecase;
  final DeleteMappedNodeUsecase deleteMappedNodeUsecase;
  final UnmappedNodeToMappedNodeUsecase unmappedNodeToMappedNodeUsecase;
  final ViewNodeDetailsMqttUsecase viewNodeDetailsMqttUsecase;

  MappingAndUnmappingNodesBloc({
    required this.fetchMappingUnmappingNodesUsecase,
    required this.deleteMappedNodeUsecase,
    required this.unmappedNodeToMappedNodeUsecase,
    required this.viewNodeDetailsMqttUsecase,
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
        },
            (success) {
          final updatedMappedNodes = currentState
              .mappingAndUnmappingNodeEntity.listOfMappedNodeEntity
              .where((e) => e.nodeId != event.mappedNodeEntity.nodeId)
              .toList();

          final updatedCategories = currentState
              .mappingAndUnmappingNodeEntity.listOfUnmappedCategoryEntity
              .map((category) {
            if (category.categoryId != event.mappedNodeEntity.categoryId) {
              return category;
            } else {
              final updatedUnmappedNodes = [
                ...category.nodes.map((e) => e.copyWith()),
                UnmappedCategoryNodeEntity(
                  nodeId: event.mappedNodeEntity.nodeId,
                  categoryId: event.mappedNodeEntity.categoryId,
                  qrCode: event.mappedNodeEntity.qrCode,
                  modelName: event.mappedNodeEntity.modelName,
                  dateManufacture: event.mappedNodeEntity.dateManufacture,
                  userName: event.mappedNodeEntity.userName,
                  mobileNumber: event.mappedNodeEntity.mobileNumber,
                ),
              ]..sort((a, b) => a.nodeId.compareTo(b.nodeId)); // more meaningful sort

              return category.copyWith(updateNodes: updatedUnmappedNodes);
            }
          }).toList();

          final updatedEntity = MappingAndUnmappingNodeEntity(
            listOfMappedNodeEntity: updatedMappedNodes,
            listOfUnmappedCategoryEntity: updatedCategories,
          );

          emit(currentState.copyWith(
            entity: updatedEntity,
            deleteStatus: DeleteMappedNodeEnum.success,
          ));
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
          mappedNodeLength: currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.length,
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
        await viewNodeDetailsMqttUsecase(ViewNodeDetailsMqttParams(
          deviceId: currentState.deviceId,
          mappedNodeEntity: event.mappedNodeEntity,
        ));
      }
    });

  }
}
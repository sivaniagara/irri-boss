import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../program_settings/sub_module/common_id_settings/data/models/category_model.dart';
import '../../domain/entities/mapped_node_entity.dart';
import '../../domain/entities/mapping_and_unmapping_node_entity.dart';
import '../../domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';
part 'mapping_and_unmapping_nodes_event.dart';
part 'mapping_and_unmapping_nodes_state.dart';

class MappingAndUnmappingNodesBloc extends Bloc<MappingAndUnmappingNodesEvent, MappingAndUnmappingNodesState>{
  final FetchMappingUnmappingNodesUsecase fetchMappingUnmappingNodesUsecase;
  MappingAndUnmappingNodesBloc({required this.fetchMappingUnmappingNodesUsecase}) : super(MappingAndUnmappingNodesInitial()){

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
                        mappingAndUnmappingNodeEntity: success
                    )
                );
              }
      );
    });
  }
}
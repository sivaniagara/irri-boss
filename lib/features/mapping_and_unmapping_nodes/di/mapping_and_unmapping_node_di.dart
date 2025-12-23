import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/bloc/mapping_and_unmapping_nodes_bloc.dart';

import '../../../core/di/injection.dart';
import '../data/data_source/mapping_and_unmapping_nodes_remote_source.dart';
import '../data/repositories/mapping_and_unmapping_nodes_repository_impl.dart';
import '../domain/repositories/mapping_and_unmapping_nodes_repository.dart';

void initMappingAndUnmappingNodeDependencies()async{
  sl.registerFactory(()=> MappingAndUnmappingNodesBloc(fetchMappingUnmappingNodesUsecase: sl()));
  sl.registerLazySingleton(()=> FetchMappingUnmappingNodesUsecase(repository: sl()));
  sl.registerLazySingleton<MappingAndUnmappingNodesRepository>(()=> MappingAndUnmappingNodesRepositoryImpl(mappingAndUnmappingNodesRemoteSource: sl()));
  sl.registerLazySingleton<MappingAndUnmappingNodesRemoteSource>(()=> MappingAndUnmappingNodesRemoteSourceImpl(apiClient: sl()));
}
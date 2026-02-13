import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mapped_node_entity.dart';
import '../repositories/mapping_and_unmapping_nodes_repository.dart';

class ViewNodeDetailsMqttUsecase implements UseCase<Unit, ViewNodeDetailsMqttParams> {
  final MappingAndUnmappingNodesRepository repository;

  ViewNodeDetailsMqttUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(ViewNodeDetailsMqttParams params) async {
    return await repository.viewNodeDetailsMqtt(params);
  }
}

class ViewNodeDetailsMqttParams {
  final String deviceId;
  final MappedNodeEntity mappedNodeEntity;

  ViewNodeDetailsMqttParams({
    required this.deviceId,
    required this.mappedNodeEntity,
  });
}

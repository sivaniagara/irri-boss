
import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../entities/category_entity.dart';
import '../entities/category_node_entity.dart';
import '../repositories/common_id_settings_repository.dart';

class ResetCommonIdParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final CategoryEntity categoryEntity;
  final List<CategoryNodeEntity> listOfCategoryNodeEntity;

  ResetCommonIdParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.categoryEntity,
    required this.listOfCategoryNodeEntity,
  });
}

class ResetCommonIdUsecase extends UseCase<Unit, ResetCommonIdParams>{
  final CommonIdSettingsRepository commonIdSettingsRepository;
  ResetCommonIdUsecase({required this.commonIdSettingsRepository});

  @override
  Future<Either<Failure, Unit>> call(ResetCommonIdParams params) async{
    return commonIdSettingsRepository.resetCommonId(params);
  }
}
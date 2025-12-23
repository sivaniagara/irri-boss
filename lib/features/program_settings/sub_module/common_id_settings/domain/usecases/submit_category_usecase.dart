
import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../entities/category_entity.dart';
import '../repositories/common_id_settings_repository.dart';

class SubmitCategoryParams{
  final String userId;
  final String controllerId;
  final CategoryEntity categoryEntity;
  SubmitCategoryParams({required this.userId, required this.controllerId, required this.categoryEntity});
}

class SubmitCategoryUsecase extends UseCase<Unit, SubmitCategoryParams>{
  final CommonIdSettingsRepository commonIdSettingsRepository;
  SubmitCategoryUsecase({required this.commonIdSettingsRepository});

  @override
  Future<Either<Failure, Unit>> call(SubmitCategoryParams params) async{
    return commonIdSettingsRepository.updateCategoryNodeSerialNo(params);
  }
}

import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../entities/category_entity.dart';
import '../repositories/common_id_settings_repository.dart';

class ViewCommonIdParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final CategoryEntity categoryEntity;
  ViewCommonIdParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.categoryEntity
  });
}

class ViewCommonIdUsecase extends UseCase<Unit, ViewCommonIdParams>{
  final CommonIdSettingsRepository commonIdSettingsRepository;
  ViewCommonIdUsecase({required this.commonIdSettingsRepository});

  @override
  Future<Either<Failure, Unit>> call(ViewCommonIdParams params) async{
    return commonIdSettingsRepository.viewCommonId(params);
  }
}
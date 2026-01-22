import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/domain/entities/category_entity.dart';

import '../repositories/common_id_settings_repository.dart';

class GetCommonIdSettingsParams{
  final String userId;
  final String controllerId;

  GetCommonIdSettingsParams({
    required this.userId,
    required this.controllerId,
  });

}

class GetCommonIdSettingsUsecase extends UseCase<List<CategoryEntity>, GetCommonIdSettingsParams>{
  final CommonIdSettingsRepository commonIdSettingsRepository;
  GetCommonIdSettingsUsecase({required this.commonIdSettingsRepository});

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(GetCommonIdSettingsParams params)async{
    return commonIdSettingsRepository.getCommonIdSettings(params);
  }
}
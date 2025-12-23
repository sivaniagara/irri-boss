import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../usecases/get_common_id_settings_usecase.dart';
import '../usecases/submit_category_usecase.dart';

abstract class CommonIdSettingsRepository{
  Future<Either<Failure, List<CategoryEntity>>> getCommonIdSettings(GetCommonIdSettingsParams params);
  Future<Either<Failure, Unit>> updateCategoryNodeSerialNo(SubmitCategoryParams params);
}
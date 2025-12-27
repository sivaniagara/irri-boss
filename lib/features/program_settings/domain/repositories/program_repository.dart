import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/success.dart';
import '../entities/program_and_zone_entity.dart';
import '../usecases/delete_zone_usecase.dart';
import '../usecases/get_programs_usecase.dart';

abstract class ProgramRepository {
  Future<Either<Failure, List<ProgramAndZoneEntity>>> getPrograms(ProgramParams params);
  Future<Either<Failure, Unit>> deleteZone(DeleteZoneParams params);
}

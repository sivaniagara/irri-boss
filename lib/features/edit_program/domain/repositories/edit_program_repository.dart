import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/edit_program_entity.dart';

import '../usecases/get_program_usecase.dart';
import '../usecases/save_program_usecase.dart';
import '../usecases/send_zone_configuration_payload_usecase.dart';
import '../usecases/send_zone_set_payload_usecase.dart';

abstract class EditProgramRepository{

  Future<Either<Failure, EditProgramEntity>> getProgram(GetProgramParams params);
  Future<Either<Failure, Unit>> saveProgram(SaveProgramParams params);
  Future<Either<Failure, Unit>> sendZoneConfigurationPayload(SendZoneConfigurationParams params);
  Future<Either<Failure, Unit>> sendZoneSetPayload(SendZoneSetPayloadParams params);
}
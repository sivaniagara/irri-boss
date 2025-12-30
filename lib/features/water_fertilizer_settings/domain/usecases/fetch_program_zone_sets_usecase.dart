import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/program_zone_set_entity.dart';
import '../repositories/water_fertilizer_settings_repository.dart';

class FetchProgramZoneSetsParams{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String programId;

  FetchProgramZoneSetsParams({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programId,
  });
}


class FetchProgramZoneSetsUsecase extends UseCase<ProgramZoneSetEntity, FetchProgramZoneSetsParams>{
  final WaterFertilizerSettingsRepository repository;
  FetchProgramZoneSetsUsecase({required this.repository});

  @override
  Future<Either<Failure, ProgramZoneSetEntity>> call(FetchProgramZoneSetsParams params)async{
    return repository.fetchProgramZoneSets(params);
  }
}
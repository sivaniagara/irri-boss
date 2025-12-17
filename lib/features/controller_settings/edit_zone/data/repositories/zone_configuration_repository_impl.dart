import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/domain/repositories/zone_configuration_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/domain/usecases/get_zone_configuration_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/domain/usecases/submit_zone_configuration_usecase.dart';
import '../../../../../core/error/success.dart';
import '../../domain/entities/zone_nodes_entity.dart';
import '../data_source/zone_configuration_remote_source.dart';
import '../models/zone_configuration_model.dart';

class ZoneConfigurationRepositoryImpl implements ZoneConfigurationRepository{
  final ZoneConfigurationRemoteSource zoneConfigurationRemoteSource;
  ZoneConfigurationRepositoryImpl({required this.zoneConfigurationRemoteSource});

  @override
  Future<Either<Failure, ZoneConfigurationEntity>>
  getZoneConfiguration(GetZoneConfigurationParams params) async {
    try {
      final response =
      await zoneConfigurationRemoteSource.getZoneConfiguration({
        'userId': params.userId,
        'controllerId': params.controllerId,
        'programId': params.programId,
      });

      final model =
      ZoneConfigurationModel.fromJson(response['data']);

      return Right(model.toEntity()); // 🔥 KEY LINE
    } catch (e) {
      return Left(
        ServerFailure('getZoneConfiguration failed: $e'),
      );
    }
  }


  @override
  Future<Either<Failure, Success>> submitZoneConfiguration(SubmitZoneConfigurationParams params) async{
    try{
      return Right(ZoneCreatedSuccess());
    }catch(e){
      return Left(ServerFailure('getZoneConfiguration failed: $e'));
    }

  }
}
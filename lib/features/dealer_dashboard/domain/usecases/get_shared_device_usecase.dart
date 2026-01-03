import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/entities/shared_devices_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/repositories/shared_devices_repositories.dart';

class GetSharedDevicesUsecase extends UseCase<List<SharedDevicesEntity>, GetSharedDevicesParams>{
  final SharedDevicesRepository repository;

  GetSharedDevicesUsecase({required this.repository});

  @override
  Future<Either<Failure, List<SharedDevicesEntity>>> call(GetSharedDevicesParams params) async {
    return await repository.getSharedDevices(params.userId);
  }
}

class GetSharedDevicesParams extends Equatable{
  final String userId;
  const GetSharedDevicesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/entities/shared_devices_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/usecases/get_shared_device_usecase.dart';

abstract class SharedDevicesState extends Equatable {
  const SharedDevicesState();
  @override
  List<Object?> get props => [];
}

class SharedDevicesInitial extends SharedDevicesState {}

class SharedDevicesLoaded extends SharedDevicesState {
  final List<SharedDevicesEntity> sharedDevices;
  const SharedDevicesLoaded({required this.sharedDevices});

  @override
  List<Object?> get props => [sharedDevices];
}

class SharedDevicesError extends SharedDevicesState {
  final String message;
  const SharedDevicesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SharedDevicesCubit extends Cubit<SharedDevicesState> {
  final GetSharedDevicesUsecase getSharedDevicesUsecase;
  SharedDevicesCubit({
    required this.getSharedDevicesUsecase
  }) : super(SharedDevicesInitial());

  Future<void> getSharedDevices(String userId) async {
    if(state is SharedDevicesLoaded) return;
    final result = await getSharedDevicesUsecase(GetSharedDevicesParams(userId: userId));

    result.fold(
            (failure) => emit(SharedDevicesError(message: failure.message)),
            (devices) => emit(SharedDevicesLoaded(sharedDevices: devices))
    );
  }
}
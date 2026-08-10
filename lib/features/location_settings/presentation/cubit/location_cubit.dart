import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/location_repository.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationSuccess extends LocationState {}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository repository;

  LocationCubit(this.repository) : super(LocationInitial());

  Future<void> setLocation({
    required int userId,
    required int controllerId,
    required String latLong,
  }) async {
    emit(LocationLoading());

    final result = await repository.updateLatLong(
      userId: userId,
      controllerId: controllerId,
      latLong: latLong,
    );

    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (success) => emit(LocationSuccess()),
    );
  }
}

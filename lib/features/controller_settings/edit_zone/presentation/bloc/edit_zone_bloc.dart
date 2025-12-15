import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_zone_configuration_usecase.dart';
import '../../domain/entities/zone_nodes_entity.dart';

part 'edit_zone_event.dart';
part 'edit_zone_state.dart';

class EditZoneBloc extends Bloc<EditZoneEvent, EditZoneState> {
  final GetZoneConfigurationUseCase getZoneNodesUseCase;

  EditZoneBloc(this.getZoneNodesUseCase) : super(EditZoneInitial()) {
    on<AddZone>((event, emit) async {
      emit(EditZoneLoading());
      GetZoneConfigurationParams params = GetZoneConfigurationParams(userId: event.userId, controllerId: event.controllerId);
      final result = await getZoneNodesUseCase(params);
      result.fold(
            (failure) => emit(EditZoneError(failure.toString())),
            (data) => emit(EditZoneLoaded(data)),
      );
    });
  }
}

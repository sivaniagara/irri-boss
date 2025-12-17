import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/node_entity.dart';
import '../../domain/usecases/get_zone_configuration_usecase.dart';
import '../../domain/entities/zone_nodes_entity.dart';

part 'edit_zone_event.dart';
part 'edit_zone_state.dart';

class EditZoneBloc extends Bloc<EditZoneEvent, EditZoneState> {
  final GetZoneConfigurationUseCase getZoneNodesUseCase;

  EditZoneBloc({required this.getZoneNodesUseCase}) : super(EditZoneInitial()) {

    on<AddZone>((event, emit) async {
      emit(EditZoneLoading());
      GetZoneConfigurationParams params = GetZoneConfigurationParams(userId: event.userId, controllerId: event.controllerId, programId: event.programId);
      final result = await getZoneNodesUseCase(params);
      result.fold(
            (failure) => emit(EditZoneError(failure.toString())),
            (data) => emit(
                EditZoneLoaded(
                    zoneNodes: data,
                    programId: event.programId,
                  userId: event.userId,
                  controllerId: event.controllerId,
                )
            ),
      );
    });


    on<ApplyValveSelection>((event, emit) {
      if (state is! EditZoneLoaded) return;

      final current = state as EditZoneLoaded;

      emit(
        EditZoneLoaded(
            zoneNodes: current.zoneNodes
                .copyWith(valves: event.valves),
            programId: current.programId,
            userId: current.userId,
            controllerId: current.controllerId,
        ),
      );
    });

    on<SubmitZone>((event, emit){

    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/node_entity.dart';
import '../../domain/usecases/edit_zone_configuration_usecase.dart';
import '../../domain/usecases/get_zone_configuration_usecase.dart';
import '../../domain/entities/zone_nodes_entity.dart';
import '../../domain/usecases/submit_zone_configuration_usecase.dart';
import '../pages/edit_zone.dart';

part 'edit_zone_event.dart';
part 'edit_zone_state.dart';

class EditZoneBloc extends Bloc<EditZoneEvent, EditZoneState> {
  final GetZoneConfigurationUseCase getZoneNodesUseCase;
  final EditZoneConfigurationUseCase editZoneNodesUseCase;
  final SubmitZoneConfigurationUsecase submitZoneConfigurationUsecase;

  EditZoneBloc({
    required this.getZoneNodesUseCase,
    required this.editZoneNodesUseCase,
    required this.submitZoneConfigurationUsecase
  }) : super(EditZoneInitial()) {

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
                  submissionStatus: ZoneSubmissionStatus.idle,
                  message: '',
                )
            ),
      );
    });

    on<EditZone>((event, emit) async {
      emit(EditZoneLoading());
      EditZoneConfigurationParams params = EditZoneConfigurationParams(
          userId: event.userId,
          controllerId: event.controllerId,
          programId: event.programId,
          zoneSerialNo: event.zoneSerialNo,
      );
      final result = await editZoneNodesUseCase(params);
      result.fold(
            (failure) => emit(EditZoneError(failure.toString())),
            (data) => emit(
            EditZoneLoaded(
              zoneNodes: data,
              programId: event.programId,
              userId: event.userId,
              controllerId: event.controllerId,
              submissionStatus: ZoneSubmissionStatus.idle,
              message: '',
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
          submissionStatus: ZoneSubmissionStatus.idle,
          message: '',
        ),
      );
    });

    on<SubmitZone>((event, emit) async {
      if (state is! EditZoneLoaded) return;

      final current = state as EditZoneLoaded;
      emit(current.copyWith(submissionStatus: ZoneSubmissionStatus.loading));

      final params = SubmitZoneConfigurationParams(
        userId: current.userId,
        controllerId: current.controllerId,
        programId: current.programId,
        zoneNodes: current.zoneNodes,
      );

      final result = await submitZoneConfigurationUsecase(params);

      result.fold(
            (failure) {
          emit(current.copyWith(submissionStatus: ZoneSubmissionStatus.failure, message: failure.message));
        },
            (unit) {
          emit(current.copyWith(submissionStatus: ZoneSubmissionStatus.success, message: 'Zone Created Successfully..'));
        },
      );
    });
  }
}

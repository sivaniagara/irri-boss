import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/node_entity.dart';
import '../../domain/usecases/edit_zone_configuration_usecase.dart';
import '../../domain/usecases/get_zone_configuration_usecase.dart';
import '../../domain/entities/zone_nodes_entity.dart';
import '../../domain/usecases/submit_while_edit_zone_configuration.dart';
import '../../domain/usecases/submit_zone_configuration_usecase.dart';
import '../enums/edit_zone_enums.dart';
import '../pages/edit_zone_page.dart';

part 'edit_zone_event.dart';
part 'edit_zone_state.dart';

class EditZoneBloc extends Bloc<EditZoneEvent, EditZoneState> {
  final GetZoneConfigurationUseCase getZoneNodesUseCase;
  final EditZoneConfigurationUseCase editZoneNodesUseCase;
  final SubmitZoneConfigurationUseCase submitZoneConfigurationUsecase;
  final SubmitWhileEditZoneConfigurationUseCase submitWhileEditZoneConfigurationUseCase;

  EditZoneBloc({
    required this.getZoneNodesUseCase,
    required this.editZoneNodesUseCase,
    required this.submitZoneConfigurationUsecase,
    required this.submitWhileEditZoneConfigurationUseCase
  }) : super(EditZoneInitial()) {

    on<AddZone>((event, emit) async {
      print('AddZone --> ** initialize **');
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
                  submitMode: SubmitMode.whenAdd,
                  message: '',
                )
            ),
      );
    });

    on<EditZone>((event, emit) async {
      print('EditZone --> ** initialize **');
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
              submitMode: SubmitMode.whenEdit,
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
          submitMode: current.submitMode
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

    on<SubmitWhileEditZone>((event, emit) async {
      if (state is! EditZoneLoaded) return;

      final current = state as EditZoneLoaded;
      emit(current.copyWith(submissionStatus: ZoneSubmissionStatus.loading));

      final params = SubmitWhileEditZoneConfigurationParams(
        userId: current.userId,
        controllerId: current.controllerId,
        programId: current.programId,
        zoneNodes: current.zoneNodes,
      );

      final result = await submitWhileEditZoneConfigurationUseCase(params);

      result.fold(
            (failure) {
          emit(current.copyWith(submissionStatus: ZoneSubmissionStatus.failure, message: failure.message));
        },
            (unit) {
          emit(current.copyWith(submissionStatus: ZoneSubmissionStatus.success, message: 'Zone Edited Successfully..'));
        },
      );
    });
  }
}

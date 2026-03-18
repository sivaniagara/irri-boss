import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_details/domain/usecase/controller_details_usercase.dart';
import '../../data/models/controller_details_model.dart';
import '../../domain/usecase/controller_details_params.dart';
import '../../domain/usecase/update_controllerDetails_params.dart';
import 'controller_details_bloc_event.dart';
import 'controller_details_state.dart';

class ControllerDetailsBloc
    extends Bloc<ControllerDetailsEvent, ControllerDetailsState> {

  final GetControllerDetailsUsecase getControllerDetails;
  final UpdateControllerUsecase updateController;

  ControllerDetailsBloc({
    required this.getControllerDetails,
    required this.updateController,
  }) : super(ControllerDetailsInitial()) {
    on<GetControllerDetailsEvent>(_onGetDetails);
    on<UpdateControllerEvent>(_onUpdateController);
    on<ToggleSwitchEvent>(_onToggleSwitch);
  }


  // --------------------------------------------------
  // 1) GET CONTROLLER DETAILS
  // --------------------------------------------------
  Future<void> _onGetDetails(
      GetControllerDetailsEvent event,
      Emitter<ControllerDetailsState> emit,
      ) async {
    emit(ControllerDetailsLoading());

    final result = await getControllerDetails(
      GetControllerDetailsParams(
        userId: event.userId,
        controllerId: event.controllerId,
        deviceId: event.deviceId,
      ),
    );

    result.fold(
          (failure) => emit(ControllerDetailsError(failure.message)),
          (success) {
        final model = success as ControllerResponseModel;

        emit(
          ControllerDetailsLoaded(
            model.controllerDetails,
            model.groupDetails,
          ),
        );
      },
    );
  }


  // --------------------------------------------------
  // 2) UPDATE CONTROLLER
  // --------------------------------------------------
  Future<void> _onUpdateController(
      UpdateControllerEvent event,
      Emitter<ControllerDetailsState> emit,
      ) async {
    emit(ControllerDetailsLoading());

    final result = await updateController(
      UpdateControllerDetailsParams(
        userId: event.userId,
        controllerId: event.controllerId,
        countryCode: event.countryCode,
        simNumber: event.simNumber,
        deviceName: event.deviceName,
        groupId: event.groupId,
        operationMode: event.operationMode,
        gprsMode: event.gprsMode,
        appSmsMode: event.appSmsMode,
        sentSms: event.sentSms,
        editType: event.editType,
      ),
    );

    result.fold(
          (failure) => emit(ControllerDetailsError(failure.message)),
          (success) => emit(UpdateControllerSuccess(success)),
    );
  }


  // --------------------------------------------------
  // 3) TOGGLE SWITCH (OPTIONAL)
  // --------------------------------------------------
  Future<void> _onToggleSwitch(
      ToggleSwitchEvent event,
      Emitter<ControllerDetailsState> emit,
      ) async {
    // Check if we already have data loaded
    if (state is ControllerDetailsLoaded) {
      final currentState = state as ControllerDetailsLoaded;

      // 1. Create a modified copy of the current data
      // Note: You need a 'copyWith' method in your ControllerDetailsEntities
      final updatedData = currentState.data.copyWith(
        gprsMode: event.switchName == "gprsMode" ? (event.isOn ? "5" : "1") : null,
        dndStatus: event.switchName == "dndStatus" ? (event.isOn ? "1" : "0") : null,
      );

      // 2. Emit the Loaded state with updated data
      // This triggers the UI to rebuild while keeping the rest of the info
      emit(ControllerDetailsLoaded(updatedData, currentState.groupDetails));
    }
  }
}

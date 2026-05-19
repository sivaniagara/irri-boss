import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/get_settings_menu_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/update_menu_status.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/pump_settings_event.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/pump_settings_state.dart';

import '../../domain/usecsases/verify_menu_password_usecase.dart';

class PumpSettingsMenuBloc extends Bloc<PumpSettingsEvent, PumpSettingsState> {
  final GetPumpSettingsMenuUsecase getSettingsMenuUsecase;
  final UpdateMenuStatusUsecase updateMenuStatusUsecase;
  final VerifyMenuPasswordUsecase verifyMenuPasswordUsecase;

  PumpSettingsMenuBloc({
    required this.getSettingsMenuUsecase,
    required this.updateMenuStatusUsecase,
    required this.verifyMenuPasswordUsecase,
  }) : super(GetPumpSettingsMenuInitial()) {

    on<GetPumpSettingsMenuEvent>((event, emit) async{
      emit(GetPumpSettingsMenuInitial());

      final result = await getSettingsMenuUsecase(
          GetPumpSettingsMenuParams(
              userId: event.userId,
              subUserId: event.subUserId,
              controllerId: event.controllerId
          )
      );

      result.fold(
          (failure) => emit(GetPumpSettingsMenuError(message: failure.message)),
          (menuList) => emit(GetPumpSettingsMenuLoaded(settingMenuList: menuList))
      );
    });

    on<UpdateHiddenFlagsEvent>((event, emit) async{
      final result = await updateMenuStatusUsecase(
          UpdateMenuStatusParams(
              userId: event.userId,
              subUserId: event.subUserId,
              controllerId: event.controllerId,
              menuEntity: event.settingsMenuEntity
          )
      );

      result.fold(
              (failure) {
                emit(UpdateMenuStatusFailure(message: failure.message));
              },
              (message) => emit(UpdateMenuStatusSuccess(message: message))
      );
    });

    on<VerifyMenuPasswordEvent>((event, emit) async {
      emit(VerifyingPasswordState());

      final result = await verifyMenuPasswordUsecase(
        VerifyMenuPasswordParams(
          password: event.password,
          modelId: event.modelId,
        ),
      );

      result.fold(
        (failure) => emit(PasswordVerificationFailure(message: failure.message)),
        (message) => emit(PasswordVerificationSuccess(message: message)),
      );
    });
  }
}
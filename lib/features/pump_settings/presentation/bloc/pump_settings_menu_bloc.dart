import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/get_settings_menu_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/pump_settings_event.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/pump_settings_state.dart';

class PumpSettingsMenuBloc extends Bloc<PumpSettingsEvent, PumpSettingsState> {
  final GetPumpSettingsMenuUsecase getSettingsMenuUsecase;

  PumpSettingsMenuBloc({
    required this.getSettingsMenuUsecase
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
  }
}
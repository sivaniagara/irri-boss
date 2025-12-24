import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/get_settings_menu_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/update_menu_status.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/pump_settings_event.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/pump_settings_state.dart';

class PumpSettingsMenuBloc extends Bloc<PumpSettingsEvent, PumpSettingsState> {
  final GetPumpSettingsMenuUsecase getSettingsMenuUsecase;
  final UpdateMenuStatusUsecase updateMenuStatusUsecase;

  PumpSettingsMenuBloc({
    required this.getSettingsMenuUsecase,
    required this.updateMenuStatusUsecase
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
      /*if (state is GetPumpSettingsMenuLoaded) {
        final currentList = (state as GetPumpSettingsMenuLoaded).settingMenuList;
        final updatedList = currentList.map((item) {
          return item.menuSettingId == event.settingsMenuEntity.menuSettingId
              ? event.settingsMenuEntity
              : item;
        }).toList();

        emit(GetPumpSettingsMenuLoaded(settingMenuList: updatedList));
      }*/

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
               /* if (state is GetPumpSettingsMenuLoaded) {
                  emit(state as GetPumpSettingsMenuLoaded);
                }*/
              },
              (message) => emit(UpdateMenuStatusSuccess(message: message))
      );
    });
  }
}
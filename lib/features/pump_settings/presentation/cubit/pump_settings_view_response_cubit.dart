import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/pump_setting_view_state.dart';

class PumpSettingsViewResponseCubit extends Cubit<PumpSettingViewState> {
  PumpSettingsViewResponseCubit() : super(PumpSettingsViewInitial());

  void onViewMessageReceived(Map<String, dynamic> message) {
    final prettyString = message['cM'] ?? 'No content';

    emit(PumpSettingsViewReceived(
     message: prettyString
    ));
  }

  void clear() => emit(PumpSettingsViewInitial());
}
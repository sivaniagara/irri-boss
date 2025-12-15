import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/mqtt/bloc/mqtt_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

import '../../../../core/di/injection.dart' as di;
import '../../../mqtt/bloc/mqtt_event.dart';
import '../../../mqtt/utils/mqtt_message_helper.dart';
import '../../domain/usecsases/get_menu_items.dart';
import '../../domain/usecsases/sms_payload_builder.dart';
import '../bloc/pump_settings_state.dart';


class PumpSettingsCubit extends Cubit<PumpSettingsState> {
  final GetPumpSettingsUsecase getPumpSettingsUsecase;

  PumpSettingsCubit({required this.getPumpSettingsUsecase}) : super(GetPumpSettingsInitial());

  Future<void> loadSettings({
    required int userId,
    required int subUserId,
    required int controllerId,
    required int menuId,
  }) async {
    emit(GetPumpSettingsInitial());

    final result = await getPumpSettingsUsecase(GetPumpSettingsParams(
      userId: userId,
      subUserId: subUserId,
      controllerId: controllerId,
      menuId: menuId,
    ));

    result.fold(
          (failure) => emit(GetPumpSettingsError(message: failure.message)),
          (menuItem) => emit(GetPumpSettingsLoaded(settings: menuItem)),
    );
  }

  void updateSettingValue(String newValue, int sectionIndex, int settingIndex,) {
    if (state is! GetPumpSettingsLoaded) return;

    final currentState = state as GetPumpSettingsLoaded;
    final template = currentState.settings.template;

    final newSections = List<SettingSectionEntity>.from(template.sections);

    final targetSection = newSections[sectionIndex];
    final newSettings = List<SettingsEntity>.from(targetSection.settings);

    newSettings[settingIndex] = newSettings[settingIndex].copyWith(value: newValue);

    newSections[sectionIndex] = targetSection.copyWith(settings: newSettings);

    final newTemplate = template.copyWith(sections: newSections);
    final newMenuItem = currentState.settings.copyWith(template: newTemplate);

    emit(GetPumpSettingsLoaded(settings: newMenuItem));
  }

  void sendCurrentSetting(int sectionIndex, int settingIndex) {
    if (state is! GetPumpSettingsLoaded) return;
    final setting = (state as GetPumpSettingsLoaded).settings.template.sections[sectionIndex].settings[settingIndex];

    final payload = SmsPayloadBuilder.build(setting);
    sendSetting(payload);
  }

  Future<void> sendSetting(String payload) async {
    final publishMessage = jsonEncode(PublishMessageHelper.settingsPayload(payload));
    di.sl.get<MqttBloc>().add(PublishMqttEvent(deviceId: '', message: publishMessage));
  }

  void updateHiddenFlag() {
    if (state is! GetPumpSettingsLoaded) return;
  }
}
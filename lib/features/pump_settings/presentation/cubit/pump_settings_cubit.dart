import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_service.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/setting_widget_type.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/send_settings_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart' as di;
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_message_helper.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../domain/usecsases/get_menu_items.dart';
import '../../domain/usecsases/sms_payload_builder.dart';
import '../bloc/pump_settings_state.dart';

class PumpSettingsCubit extends Cubit<PumpSettingsState> {
  final GetPumpSettingsUsecase getPumpSettingsUsecase;
  final SendPumpSettingsUsecase sendPumpSettingsUsecase;
  final SharedPreferences sharedPreferences;

  PumpSettingsCubit({
    required this.getPumpSettingsUsecase,
    required this.sendPumpSettingsUsecase,
    required this.sharedPreferences,
  }) : super(GetPumpSettingsInitial());

  String _getPrefKey({
    required int userId,
    required int subUserId,
    required int controllerId,
    required int menuId,
    required int sectionIndex,
    required int settingIndex,
  }) {
    return 'psv_${userId}_${subUserId}_${controllerId}_${menuId}_${sectionIndex}_$settingIndex';
  }

  Future<void> loadSettings({
    required int userId,
    required int subUserId,
    required int controllerId,
    required int menuId,
  }) async {
    if (state is GetPumpSettingsLoaded) return;

    final result = await getPumpSettingsUsecase(GetPumpSettingsParams(
      userId: userId,
      subUserId: subUserId,
      controllerId: controllerId,
      menuId: menuId,
    ));

    result.fold(
          (failure) => emit(GetPumpSettingsError(message: failure.message)),
          (menuItem) {
            final updatedSections = menuItem.template.sections.asMap().entries.map((sectionEntry) {
              final sectionIndex = sectionEntry.key;
              final section = sectionEntry.value;

              final updatedSettings = section.settings.asMap().entries.map((settingEntry) {
                final settingIndex = settingEntry.key;
                final setting = settingEntry.value;

                final key = _getPrefKey(
                  userId: userId,
                  subUserId: subUserId,
                  controllerId: controllerId,
                  menuId: menuId,
                  sectionIndex: sectionIndex,
                  settingIndex: settingIndex,
                );
                final savedValue = sharedPreferences.getString(key);

                if (savedValue != null && savedValue.isNotEmpty) {
                  return setting.copyWith(value: savedValue);
                }
                return setting;
              }).toList();

              return section.copyWith(settings: updatedSettings);
            }).toList();

            final updatedMenuItem = menuItem.copyWith(
              template: menuItem.template.copyWith(sections: updatedSections),
            );

            emit(GetPumpSettingsLoaded(settings: updatedMenuItem));
          },
    );
  }

  void updateSettingValue(
      String newValue,
      int sectionIndex,
      int settingIndex,
      MenuItemEntity menuItemEntity,
      {
        bool isHiddenFlag = false,
        int? userId,
        int? subUserId,
        int? controllerId,
      }
      ) {
    final newSections = List<SettingSectionEntity>.from(menuItemEntity.template.sections);
    final targetSection = newSections[sectionIndex];
    final newSettings = List<SettingsEntity>.from(targetSection.settings);

    String processedValue = newValue;

    if (!isHiddenFlag) {
      final setting = newSettings[settingIndex];

      if (setting.widgetType == SettingWidgetType.text) {
        final trimmed = newValue.trim();
        if(setting.title == 'Dry Run Occurance Count') {
          final val = newValue.contains('.') ? newValue.split('.')[0] : newValue;
          final number = int.tryParse(val);
          if (number != null) {
            processedValue = number.toString().padLeft(2, '0');
          } else {
            processedValue = val;
          }
        } else if (menuItemEntity.menu.menuSettingId == 508) {
          processedValue = trimmed;
        } else {
          if (trimmed.isEmpty) {
            processedValue = trimmed;
          } else if (trimmed.contains('.')) {
            final parts = trimmed.split('.');
            final integerStr = parts[0];
            final decimalPart = parts.length > 1 ? parts[1] : '0';

            final intClean = integerStr.replaceAll(RegExp(r'^0+'), '');
            final intValue = intClean.isEmpty ? 0 : int.tryParse(intClean) ?? -1;

            String paddedInteger;
            if (intValue >= 0 && intValue < 100) {
              paddedInteger = intValue.toString().padLeft(3, '0');
            } else {
              paddedInteger = integerStr;
            }

            processedValue = '$paddedInteger.$decimalPart';
          } else {
            final number = int.tryParse(trimmed);
            if (number != null) {
              if (number < 100) {
                processedValue = "${number.toString().padLeft(3, '0')}.0";
              } else {
                processedValue = "${number.toString()}.0";
              }
            } else {
              processedValue = "$trimmed.0";
            }
          }
        }
      }

      newSettings[settingIndex] = setting.copyWith(value: processedValue);

      // Save to SharedPreferences
      if (userId != null && subUserId != null && controllerId != null) {
        final key = _getPrefKey(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
          menuId: menuItemEntity.menu.menuSettingId,
          sectionIndex: sectionIndex,
          settingIndex: settingIndex,
        );
        sharedPreferences.setString(key, processedValue);
      }
    } else {
      newSettings[settingIndex] = newSettings[settingIndex].copyWith(hiddenFlag: newValue);
    }

    newSections[sectionIndex] = targetSection.copyWith(settings: newSettings);
    final newTemplate = menuItemEntity.template.copyWith(sections: newSections);
    final newMenuItem = menuItemEntity.copyWith(template: newTemplate);

    emit(GetPumpSettingsLoaded(settings: newMenuItem));
  }

  void sendCurrentSetting(
      int sectionIndex,
      int settingIndex,
      String deviceId,
      int userId,
      int subUserId,
      int controllerId,
      MenuItemEntity menuItemEntity,
      ) async {
    emit(SettingSendingState(sectionIndex, settingIndex));

    final setting = menuItemEntity.template.sections[sectionIndex].settings[settingIndex];
    String payload = SmsPayloadBuilder.build(setting, deviceId);

    if (menuItemEntity.menu.menuSettingId == 508 &&
        menuItemEntity.template.sections[sectionIndex].typeId == 1 &&
        setting.serialNumber <= 4) {
      payload = '';
    }

    try {
      final publishMessage = jsonEncode(PublishMessageHelper.settingsPayload(payload));
      if(payload.isNotEmpty) {
        di.sl.get<MqttManager>().publish(deviceId, publishMessage);
      }
      final result = await sendPumpSettingsUsecase(SendPumpSettingsParams(
        userId: userId,
        subUserId: subUserId,
        controllerId: controllerId,
        menuId: menuItemEntity.menu.menuSettingId,
        menuItemEntity: menuItemEntity,
        sentSms: payload,
      ));

      result.fold(
            (failure) => emit(SettingsFailureState(message: "${setting.title} sending ${failure.message}")),
            (message) => emit(SettingsSendSuccessState(message: "${setting.title} sent $message")),
      );
    } catch (e) {
      emit(SettingsFailureState(message: "Failed to send setting: ${e.toString()}"));
    } finally {
      emit(GetPumpSettingsLoaded(settings: menuItemEntity));
    }
  }

  Future<void> updateHiddenFlags({
    required int userId,
    required int subUserId,
    required int controllerId,
    required MenuItemEntity menuItemEntity,
    required String sentSms
  }) async {
    emit(SettingsSendStartedState());
    try {
      final result = await sendPumpSettingsUsecase(SendPumpSettingsParams(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
          menuId: menuItemEntity.menu.menuSettingId,
          menuItemEntity: menuItemEntity,
          sentSms: sentSms
      ));

      result.fold(
            (failure) => emit(SettingsFailureState(message: failure.message)),
            (message) => emit(SettingsSendSuccessState(message: message)),
      );
    } catch (e) {
      emit(SettingsFailureState(message: "Failed to send settings to device: ${e.toString()}"));
    } finally {
      emit(GetPumpSettingsLoaded(settings: menuItemEntity));
    }
  }

  void getViewSettings(Map<String, dynamic> message) {
    final prettyString = message['cM'];

    final timestamp = DateTime.now().toString().substring(0, 19);
    final displayText = '[$timestamp] Device response:\n$prettyString';

    print("state :: $state");
    if (state is GetPumpSettingsLoaded) {
      final current = state as GetPumpSettingsLoaded;
      emit(current.copyWith(lastReceivedViewMessage: displayText));
    }

    print("Device view settings received:\n$prettyString");
  }
}

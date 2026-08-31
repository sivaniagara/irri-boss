import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_constants.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/setting_widget_type.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/send_settings_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/ble/mqtt_or_ble.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../domain/usecsases/get_menu_items.dart';
import '../../domain/usecsases/sms_payload_builder.dart';
import '../bloc/pump_settings_state.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

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

  String _getSubHiddenPrefKey({
    required int userId,
    required int subUserId,
    required int controllerId,
    required int menuId,
    required int sectionIndex,
    required int settingIndex,
    required int subIndex,
  }) {
    return 'pshf_${userId}_${subUserId}_${controllerId}_${menuId}_${sectionIndex}_${settingIndex}_$subIndex';
  }

  Future<void> loadSettings({
    required int userId,
    required int subUserId,
    required int controllerId,
    required int menuId,
    required int modelId,
  }) async {
    // ✅ Always reset and fetch fresh for each menu navigation
    emit(GetPumpSettingsInitial());

    final result = await getPumpSettingsUsecase(GetPumpSettingsParams(
      userId: userId,
      subUserId: subUserId,
      controllerId: controllerId,
      menuId: menuId,
      modelId: modelId,
    ));

    result.fold(
          (failure) => emit(GetPumpSettingsError(message: failure.message)),
          (menuItem) {
        final updatedSections = menuItem.template.sections.map((section) {
          final updatedSettings = section.settings.map((setting) {
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
      MenuItemEntity menuItemEntity, {
        bool isHiddenFlag = false,
        int? userId,
        int? subUserId,
        int? controllerId,
      }) {
    final newSections =
    List<SettingSectionEntity>.from(menuItemEntity.template.sections);
    final targetSection = newSections[sectionIndex];
    final newSettings = List<SettingsEntity>.from(targetSection.settings);

    String processedValue = newValue;

    if (!isHiddenFlag) {
      final setting = newSettings[settingIndex];

      if (setting.title == 'Dry Run Occurrence Count') {
        final val = newValue.contains('.') ? newValue.split('.')[0] : newValue;
        final number = int.tryParse(val);
        if (number != null) {
          processedValue = number.toString().padLeft(2, '0');
        } else {
          processedValue = val;
        }
      } else if (menuItemEntity.menu.menuSettingId == 508) {
        processedValue = newValue.trim();
      } else if (setting.widgetType == SettingWidgetType.floatText) {
        final trimmed = newValue.trim();
        if (trimmed.isEmpty) {
          processedValue = trimmed;
        } else if (trimmed.contains('.')) {
          final parts = trimmed.split('.');
          final integerStr = parts[0];
          final decimalPart = parts.length > 1 ? parts[1] : '0';

          final intClean = integerStr.replaceAll(RegExp(r'^0+'), '');
          final intValue =
          intClean.isEmpty ? 0 : int.tryParse(intClean) ?? -1;

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
              processedValue = number.toString();
            }
          } else {
            processedValue = trimmed;
          }
        }
      } else {
        // text, toggle, time, multiTime, fullText, phone, multiText, nothing, etc.
        // no transformation — just pass the raw input through
        processedValue = newValue;
      }

      newSettings[settingIndex] = setting.copyWith(value: processedValue);

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
      newSettings[settingIndex] =
          newSettings[settingIndex].copyWith(hiddenFlag: newValue);
    }

    newSections[sectionIndex] = targetSection.copyWith(settings: newSettings);
    final newTemplate = menuItemEntity.template.copyWith(sections: newSections);
    final newMenuItem = menuItemEntity.copyWith(template: newTemplate);

    emit(GetPumpSettingsLoaded(settings: newMenuItem));
  }

  /// ✅ Called by PumpSettingsDispatcher when a BLE view-response payload arrives.
  ///
  /// BLE payload format (same as _buildWlcPayload output):
  ///   "DELAY,val1,val2,val3,..."
  ///   index 0  → command word (DELAY / TIMER / SUMP / CURRENT / VOLTAGE / OTHER)
  ///   index 1+ → setting values in the same order as sections → settings
  ///
  /// Since PumpSettingsCubit is a lazySingleton, the state here is the SAME
  /// state that PumpSettingsPage's BlocBuilder is listening to.
  /// Emitting GetPumpSettingsLoaded with updated values will directly
  /// refresh every widget on screen.
  void onViewMessageReceived(String message) {
    kdebugmode('BLE view payload received: $message');

    if (state is! GetPumpSettingsLoaded) {
      kdebugmode('onViewMessageReceived: state is not loaded, ignoring payload');
      return;
    }

    final current = state as GetPumpSettingsLoaded;
    final menuItem = current.settings;

    // Split payload: ["DELAY", "val1", "val2", ...]
    final parts = message.split(';');
    if (parts.isEmpty) {
      kdebugmode('onViewMessageReceived: payload too short, ignoring');
      return;
    }

    // Skip index 0 (the command word), actual values start at index 1
    final values = parts.sublist(1);
    Map<String, dynamic> sNoAndValue = {};
    for(var set in parts){
      List<String> splitSet = set.split(',');
      if(set.contains(',') && splitSet.length == 2){
        String sNo = splitSet[0].trim();
        sNoAndValue[sNo] = splitSet[1].trim();
      }
    }
    final updatedSections = menuItem.template.sections.map((section) {
      final updatedSettings = section.settings.map((setting) {
        String settingSno = setting.serialNumber.toString();
        String value = '';
        if(setting.widgetType == SettingWidgetType.toggle){
          value = sNoAndValue[settingSno] == '1' ? 'ON': 'OFF';
        }else{
          value = sNoAndValue.containsKey(settingSno) ? sNoAndValue[settingSno] : 'N/A';
        }
        return setting.copyWith(valueInHw: value);
      }).toList();

      return section.copyWith(settings: updatedSettings);
    }).toList();

    final updatedTemplate =
    menuItem.template.copyWith(sections: updatedSections);
    final updatedMenuItem = menuItem.copyWith(template: updatedTemplate);

    // ✅ Emit updated state — BlocBuilder in PumpSettingsPage rebuilds
    // and all widgets receive the new values from the device.
    emit(GetPumpSettingsLoaded(settings: updatedMenuItem));

    kdebugmode('onViewMessageReceived: state updated with ${values.length} values from BLE');
  }

  void sendPumpSettingViewCommand({
    required String deviceId,
    required MenuItemEntity menuItemEntity,
  }) {
    String command = '';
    int menuSettingId = menuItemEntity.menu.menuSettingId;
    if ([532, 538].contains(menuSettingId)) {
      command = 'DELAY';
    } else if ([533, 541].contains(menuSettingId)) {
      command = 'TIMER';
    } else if ([534, 547].contains(menuSettingId)) {
      command = 'SUMP';
    } else if ([535, 539].contains(menuSettingId)) {
      command = 'CURRENT';
    }else if ([536, 540].contains(menuSettingId)) {
      command = 'VOLTAGE';
    } else if ([542].contains(menuSettingId)) {
      command = 'SMS';
    } else if ([543].contains(menuSettingId)) {
      command = 'COMMUNICATION';
    } else if ([544].contains(menuSettingId)) {
      command = 'STATUS_CHECK';
    } else if ([545].contains(menuSettingId)) {
      command = 'NUM_REG';
    } else if ([537, 546].contains(menuSettingId)) {
      command = 'OTHER';
    } else if ([548].contains(menuSettingId)) {
      command = 'NOTIFICATION';
    }
    di.sl<MqttOrBle>().publish(
        deviceId, AppConstants.sendWlcCommand('${command}VIEW'));
  }

  void sendCurrentSetting(
      int sectionIndex,
      int settingIndex,
      String deviceId,
      int userId,
      int subUserId,
      int controllerId,
      MenuItemEntity menuItemEntity,
      int modelId,
      String menuName,
      ) async {
    emit(SettingSendingState(sectionIndex, settingIndex));

    final setting =
    menuItemEntity.template.sections[sectionIndex].settings[settingIndex];
    final bool sendFullSetting = (
        AppConstants.sendFullSetting(modelId)
            &&
            !AppConstants.statusCheck(menuItemEntity.menu.menuSettingId)
    );

    String payload;

    if (sendFullSetting) {
      payload = _buildWlcPayload(
          menuItemEntity, sectionIndex, settingIndex, setting, deviceId);
    } else {
      payload = SmsPayloadBuilder.build(setting, deviceId, modelId: modelId);
      if (menuItemEntity.menu.menuSettingId == 531 &&
          sectionIndex == 0 &&
          settingIndex == 1) {
        payload = '${setting.value}${setting.smsFormat}';
      }
      if (menuItemEntity.menu.menuSettingId == 508 &&
          menuItemEntity.template.sections[sectionIndex].typeId == 1 &&
          setting.serialNumber <= 4) {
        payload = '';
      }
    }

    try {
      final publishMessage =
      jsonEncode(PublishMessageHelper.settingsPayload(payload));
      if (payload.isNotEmpty) {
        di.sl<MqttOrBle>().publish(
            deviceId,
            (sendFullSetting || AppConstants.isWlc(modelId))
                ? AppConstants.sendWlcCommand(payload)
                : publishMessage);
      }
      final result = await sendPumpSettingsUsecase(SendPumpSettingsParams(
        userId: userId,
        subUserId: subUserId,
        controllerId: controllerId,
        menuId: menuItemEntity.menu.menuSettingId,
        menuItemEntity: menuItemEntity,
        sentSms: payload,
        modelId: modelId,
      ));

      result.fold(
            (failure) => emit(SettingsFailureState(
            message:
            "${sendFullSetting ? menuName : setting.title} sending ${failure.message}")),
            (message) => emit(SettingsSendSuccessState(
            message: "${sendFullSetting ? menuName : setting.title} sent $message")),
      );
    } catch (e) {
      emit(SettingsFailureState(
          message: "Failed to send setting: ${e.toString()}"));
    } finally {
      emit(GetPumpSettingsLoaded(settings: menuItemEntity));
    }
  }

  String _buildWlcPayload(
      MenuItemEntity menuItemEntity,
      int sectionIndex,
      int settingIndex,
      dynamic setting,
      String deviceId,
      ) {
    final title = setting.title.toString().toLowerCase();
    final menuTitle = menuItemEntity.menu.menuItem.toLowerCase();
    if (title.contains('date') || menuTitle.contains('date')) {
      return AppConstants.formatWlcDateTime();
    }
    List<dynamic> payload = [];

    int menuSettingId = menuItemEntity.menu.menuSettingId;
    if ([503, 532, 538].contains(menuSettingId)) {
      payload.add('DELAY');
    } else if ([533, 541].contains(menuSettingId)) {
      payload.add('TIMER');
    } else if ([534, 547].contains(menuSettingId)) {
      payload.add('SUMP');
    } else if ([535, 539].contains(menuSettingId)) {
      payload.add('CURRENT');
    } else if ([536, 540].contains(menuSettingId)) {
      payload.add('VOLTAGE');
    } else if ([542].contains(menuSettingId)) {
      payload.add('SMS');
    } else if ([543].contains(menuSettingId)) {
      payload.add('COMMUNICATION');
    } else if ([544].contains(menuSettingId)) {
      payload.add('STATUS_CHECK');
    } else if ([545].contains(menuSettingId)) {
      payload.add('NUM_REG');
    } else if ([537, 546].contains(menuSettingId)) {
      payload.add('OTHER');
    } else if ([548].contains(menuSettingId)) {
      payload.add('NOTIFICATION');
    }

    for (var category in menuItemEntity.template.sections) {
      for (var categorySetting in category.settings) {
        if (categorySetting.value == 'OF') {
          payload.add('0');
        } else if (categorySetting.value == 'ON') {
          payload.add('1');
        }else if (categorySetting.value.contains(":")) {
          payload.add(categorySetting.value.split(':').join(','));
        }else if(categorySetting.widgetType == SettingWidgetType.phone){
          print("categorySetting.value : ${categorySetting.value}");
          final phone = PhoneNumber.fromCompleteNumber(completeNumber: categorySetting.value);
          final List<String> parts = categorySetting.smsFormat.split(",");
          print("phone : ${phone}");
          payload.add(categorySetting.value.isEmpty ?  "," : "+${phone.countryCode},${phone.number}");
          print("payload : ${payload}");
        } else {
          payload.add(categorySetting.value.toString());
        }
      }
    }
    kdebugmode('wlc payload: $payload');
    return payload.join(',');
  }

  Future<void> updateHiddenFlags({
    required int userId,
    required int subUserId,
    required int controllerId,
    required MenuItemEntity menuItemEntity,
    required String sentSms,
    required int modelId,
  }) async {
    emit(SettingsSendStartedState());
    try {
      final result = await sendPumpSettingsUsecase(SendPumpSettingsParams(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
          menuId: menuItemEntity.menu.menuSettingId,
          menuItemEntity: menuItemEntity,
          sentSms: sentSms,
          modelId: modelId));

      result.fold(
            (failure) => emit(SettingsFailureState(message: failure.message)),
            (message) => emit(SettingsSendSuccessState(message: message)),
      );
    } catch (e) {
      emit(SettingsFailureState(
          message: "Failed to send settings to device: ${e.toString()}"));
    } finally {
      emit(GetPumpSettingsLoaded(settings: menuItemEntity));
    }
  }

  bool isSubSettingVisible({
    required int userId,
    required int subUserId,
    required int controllerId,
    required int menuId,
    required int sectionIndex,
    required int settingIndex,
    required int subIndex,
    required bool defaultVisible,
  }) {
    final key = _getSubHiddenPrefKey(
      userId: userId,
      subUserId: subUserId,
      controllerId: controllerId,
      menuId: menuId,
      sectionIndex: sectionIndex,
      settingIndex: settingIndex,
      subIndex: subIndex,
    );
    return sharedPreferences.getBool(key) ?? defaultVisible;
  }

  Future<void> updateSubSettingVisibility({
    required int userId,
    required int subUserId,
    required int controllerId,
    required int menuId,
    required int sectionIndex,
    required int settingIndex,
    required int subIndex,
    required bool isVisible,
  }) async {
    final key = _getSubHiddenPrefKey(
      userId: userId,
      subUserId: subUserId,
      controllerId: controllerId,
      menuId: menuId,
      sectionIndex: sectionIndex,
      settingIndex: settingIndex,
      subIndex: subIndex,
    );
    await sharedPreferences.setBool(key, isVisible);

    if (state is GetPumpSettingsLoaded) {
      final current = state as GetPumpSettingsLoaded;
      emit(current.copyWith(version: current.version + 1));
    }
  }

  void getViewSettings(Map<String, dynamic> message) {
    final prettyString = message['cM'];
    final timestamp = DateTime.now().toString().substring(0, 19);
    final displayText = '[$timestamp] Device response:\n$prettyString';

    kdebugmode("state :: $state");
    if (state is GetPumpSettingsLoaded) {
      final current = state as GetPumpSettingsLoaded;
      emit(current.copyWith(lastReceivedViewMessage: displayText));
    }

    kdebugmode("Device view settings received:\n$prettyString");
  }
}
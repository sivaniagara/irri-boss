import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/phone_number.dart';

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

  MenuItemEntity? twoPhaseMenuItem;
  int selectedPump = 1;

  PumpSettingsCubit({
    required this.getPumpSettingsUsecase,
    required this.sendPumpSettingsUsecase,
    required this.sharedPreferences,
  }) : super(GetPumpSettingsInitial());

  void selectPump(int pump) {
    selectedPump = pump;
    if (state is GetPumpSettingsLoaded) {
      final current = state as GetPumpSettingsLoaded;
      emit(current.copyWith(version: current.version + 1));
    }
  }

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
    selectedPump = 1;
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

        if (menuId == 502) {
          twoPhaseMenuItem = updatedMenuItem;
        }

        emit(GetPumpSettingsLoaded(settings: updatedMenuItem));
      },
    );
  }

  void updateSettingValue(
    String newValue,
    int sectionIndex,
    int settingIndex, {
    bool isHiddenFlag = false,
    bool isPump2 = false,
    int? userId,
    int? subUserId,
    int? controllerId,
  }) {
    if (state is! GetPumpSettingsLoaded) return;
    final currentLoadedState = state as GetPumpSettingsLoaded;
    final menuItemEntity = currentLoadedState.settings;

    final targetSections =
        (isPump2 && menuItemEntity.template.p2Sections.isNotEmpty)
            ? menuItemEntity.template.p2Sections
            : menuItemEntity.template.sections;

    final newSections = List<SettingSectionEntity>.from(targetSections);
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
    final newTemplate =
        (isPump2 && menuItemEntity.template.p2Sections.isNotEmpty)
            ? menuItemEntity.template.copyWith(p2Sections: newSections)
            : menuItemEntity.template.copyWith(sections: newSections);
    final newMenuItem = menuItemEntity.copyWith(template: newTemplate);

    if (menuItemEntity.menu.menuSettingId == 502) {
      twoPhaseMenuItem = newMenuItem;
    }

    emit(GetPumpSettingsLoaded(settings: newMenuItem));
  }

  void onViewMessageReceived(String message) {
    kdebugmode('Device view payload received: $message');

    if (state is! GetPumpSettingsLoaded) {
      kdebugmode(
          'onViewMessageReceived: state is not loaded, ignoring payload');
      return;
    }

    final current = state as GetPumpSettingsLoaded;
    final menuItem = current.settings;


    String cleanMessage = message;
    if (cleanMessage.startsWith('{') && cleanMessage.endsWith('}')) {
      cleanMessage = cleanMessage.substring(1, cleanMessage.length - 1);
      int lastComma = cleanMessage.lastIndexOf(',');
      if (lastComma != -1) {
        cleanMessage = cleanMessage.substring(0, lastComma);
      }
    }

    List<String> rawParts = cleanMessage.split(',');
    List<String> parts = [];
    for (var p in rawParts) {
      if (p.contains(';')) {
        final subParts = p.split(';');
        for (var sub in subParts) {
          if (sub.trim().isNotEmpty) {
            parts.add(sub.trim());
          }
        }
      } else {
        parts.add(p.trim());
      }
    }

    if (parts.isEmpty) {
      kdebugmode('onViewMessageReceived: payload too short, ignoring');
      return;
    }

    String command = parts[0].trim().toUpperCase();
    int valueIndex = 1;
    bool isPump2Payload = selectedPump == 2;

    if (['DELAY', 'TIMER', 'SUMP', 'CURRENT'].contains(command)) {
      if (parts.length > 1) {
        String pumpNum = parts[1].trim();
        isPump2Payload = (pumpNum == '2');
      }
    }

    final targetSections =
        (isPump2Payload && menuItem.template.p2Sections.isNotEmpty)
            ? menuItem.template.p2Sections
            : menuItem.template.sections;

    final updatedSections = targetSections.map((section) {
      final updatedSettings = section.settings.map((setting) {
        if (valueIndex >= parts.length) {
          return setting;
        }

        String rawValue = parts[valueIndex].trim();
        if (RegExp(r'^\d+:').hasMatch(rawValue)) {
          rawValue = rawValue.replaceFirst(RegExp(r'^\d+:'), '').trim();
        }

        String value = '';
        if (setting.widgetType == SettingWidgetType.time ||
            setting.widgetType == SettingWidgetType.multiTime ||
            setting.value.contains(':')) {
          if (rawValue.contains(':')) {
            final tParts = rawValue.split(':');
            if (tParts.length == 3) {
              if (tParts[0] == '00' && tParts[1] != '00') {
                value = '${tParts[1].padLeft(2, '0')}:${tParts[2].padLeft(2, '0')}:00';
              } else {
                value = '${tParts[0].padLeft(2, '0')}:${tParts[1].padLeft(2, '0')}:${tParts[2].padLeft(2, '0')}';
              }
            } else if (tParts.length == 2) {
              value = '${tParts[0].padLeft(2, '0')}:${tParts[1].padLeft(2, '0')}:00';
            } else {
              value = rawValue;
            }
            valueIndex++;
          } else if (valueIndex + 2 < parts.length) {
            String hh = parts[valueIndex].trim().padLeft(2, '0');
            String mm = parts[valueIndex + 1].trim().padLeft(2, '0');
            String ss = parts[valueIndex + 2].trim().padLeft(2, '0');
            value = '$hh:$mm:$ss';
            valueIndex += 3;
          } else {
            valueIndex++;
          }
        } else if (setting.widgetType == SettingWidgetType.phone) {
          if (valueIndex + 1 < parts.length) {
            String cc = parts[valueIndex].trim();
            String num = parts[valueIndex + 1].trim();
            if (cc.startsWith('+')) {
              value = '$cc$num';
            } else {
              value = '+$cc$num';
            }
            valueIndex += 2;
          } else {
            valueIndex++;
          }
        } else {
          if (setting.widgetType == SettingWidgetType.toggle) {
            value = (rawValue == '1' || rawValue.toUpperCase() == 'ON') ? 'ON' : 'OF';
          } else {
            value = rawValue;
          }
          valueIndex++;
        }

        if (value.isNotEmpty && !value.contains(';')) {
          return setting.copyWith(value: value, valueInHw: value);
        }
        return setting;
      }).toList();

      return section.copyWith(settings: updatedSettings);
    }).toList();

    final updatedTemplate =
        (isPump2Payload && menuItem.template.p2Sections.isNotEmpty)
            ? menuItem.template.copyWith(p2Sections: updatedSections)
            : menuItem.template.copyWith(sections: updatedSections);

    final updatedMenuItem = menuItem.copyWith(template: updatedTemplate);

    emit(GetPumpSettingsLoaded(settings: updatedMenuItem));
    kdebugmode('onViewMessageReceived: state updated from BLE');
  }

  void sendPumpSettingViewCommand({
    required String deviceId,
    required MenuItemEntity menuItemEntity,
    required int modelId,
  }) {
    String command = '';
    int menuSettingId = menuItemEntity.menu.menuSettingId;

    if ([503, 532, 538].contains(menuSettingId)) {
      command = 'DELAY';
    } else if ([533, 541].contains(menuSettingId)) {
      command = 'TIMER';
    } else if ([534, 547].contains(menuSettingId)) {
      command = 'SUMP';
    } else if ([535, 539].contains(menuSettingId)) {
      command = 'CURRENT';
    } else if ([536, 540].contains(menuSettingId)) {
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

    if (command.isEmpty) {
      final menuTitle = menuItemEntity.menu.menuItem.toLowerCase();
      if (menuTitle.contains('delay'))
        command = 'DELAY';
      else if (menuTitle.contains('timer'))
        command = 'TIMER';
      else if (menuTitle.contains('sump'))
        command = 'SUMP';
      else if (menuTitle.contains('current'))
        command = 'CURRENT';
      else if (menuTitle.contains('voltage'))
        command = 'VOLTAGE';
      else if (menuTitle.contains('sms'))
        command = 'SMS';
      else if (menuTitle.contains('communication'))
        command = 'COMMUNICATION';
      else if (menuTitle.contains('other'))
        command = 'OTHER';
      else if (menuTitle.contains('notification'))
        command = 'NOTIFICATION';
      else
        command = menuTitle.split(' ').first.toUpperCase();
    }

    if (AppConstants.isIrrigationLive(modelId)) {
      command = command.toLowerCase();
    }

    String payload = '${command}VIEW';

    bool hasPumpNumber = ['delay', 'timer', 'sump', 'current'].contains(command.toLowerCase());
    if (hasPumpNumber) {
      payload += ',$selectedPump';
    }

    String finalPayload;
    if (AppConstants.isIrrigationLive(modelId)) {
      String innerPayload = AppConstants.sendWlcCommand(payload, appendCrc: false, includeBrackets: false);
      finalPayload = jsonEncode(PublishMessageHelper.settingsPayload(innerPayload));
    } else {
      finalPayload = AppConstants.sendWlcCommand(payload, appendCrc: true, includeBrackets: true);
    }

    di.sl<MqttOrBle>().publish(deviceId, finalPayload);
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
    String menuName, {
    bool isPump2 = false,
  }) async {
    emit(SettingSendingState(sectionIndex, settingIndex));

    final targetSections =
        (isPump2 && menuItemEntity.template.p2Sections.isNotEmpty)
            ? menuItemEntity.template.p2Sections
            : menuItemEntity.template.sections;

    final setting = (targetSections.isNotEmpty &&
            sectionIndex < targetSections.length &&
            settingIndex < targetSections[sectionIndex].settings.length)
        ? targetSections[sectionIndex].settings[settingIndex]
        : menuItemEntity.template.sections[0].settings[0];

    final bool sendFullSetting = (AppConstants.sendFullSetting(modelId) &&
        !AppConstants.statusCheck(menuItemEntity.menu.menuSettingId));

    String payload;

    if (sendFullSetting) {
      payload = _buildWlcPayload(
          menuItemEntity, sectionIndex, settingIndex, setting, deviceId,
          isPump2: isPump2, modelId: modelId);
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
        String finalPayload;
        if (sendFullSetting || AppConstants.isWlc(modelId)) {
          if (AppConstants.isIrrigationLive(modelId)) {
            String innerPayload = AppConstants.sendWlcCommand(payload, appendCrc: false, includeBrackets: false);
            finalPayload = jsonEncode(PublishMessageHelper.settingsPayload(innerPayload));
          } else {
            finalPayload = AppConstants.sendWlcCommand(payload, appendCrc: true, includeBrackets: true);
          }
        } else {
          finalPayload = publishMessage;
        }

        di.sl<MqttOrBle>().publish(deviceId, finalPayload);
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
            message:
                "${sendFullSetting ? menuName : setting.title} sent $message")),
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
    String deviceId, {
    bool isPump2 = false,
    int modelId = 1,
  }) {
    final title = setting.title.toString().toLowerCase();
    final menuTitle = menuItemEntity.menu.menuItem.toLowerCase();
    if (title.contains('date') || menuTitle.contains('date')) {
      return AppConstants.formatWlcDateTime();
    }
    List<dynamic> payload = [];

    int menuSettingId = menuItemEntity.menu.menuSettingId;

    String command = '';
    if ([503, 532, 538].contains(menuSettingId)) {
      command = 'DELAY';
    } else if ([533, 541].contains(menuSettingId)) {
      command = 'TIMER';
    } else if ([534, 547].contains(menuSettingId)) {
      command = 'SUMP';
    } else if ([535, 539].contains(menuSettingId)) {
      command = 'CURRENT';
    } else if ([536, 540].contains(menuSettingId)) {
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

    if (command.isEmpty) {
      if (menuTitle.contains('delay'))
        command = 'DELAY';
      else if (menuTitle.contains('timer'))
        command = 'TIMER';
      else if (menuTitle.contains('sump'))
        command = 'SUMP';
      else if (menuTitle.contains('current'))
        command = 'CURRENT';
      else if (menuTitle.contains('voltage'))
        command = 'VOLTAGE';
      else if (menuTitle.contains('sms'))
        command = 'SMS';
      else if (menuTitle.contains('communication'))
        command = 'COMMUNICATION';
      else if (menuTitle.contains('other'))
        command = 'OTHER';
      else if (menuTitle.contains('notification'))
        command = 'NOTIFICATION';
      else
        command = menuTitle.split(' ').first.toUpperCase();
    }

    if (command.isNotEmpty) {
      if (AppConstants.isIrrigationLive(modelId)) {
        command = command.toLowerCase();
      }
      payload.add(command);
    }

    bool hasPumpNumber = ['delay', 'timer', 'sump', 'current'].contains(command.toLowerCase());
    if (hasPumpNumber) {
      payload.add(isPump2 ? '2' : '1');
    }

    final targetSections =
        (isPump2 && menuItemEntity.template.p2Sections.isNotEmpty)
            ? menuItemEntity.template.p2Sections
            : menuItemEntity.template.sections;

    for (var category in targetSections) {
      for (var categorySetting in category.settings) {
        if (!_isSettingVisible(menuItemEntity, categorySetting, modelId)) {
          continue;
        }

        if (categorySetting.value == 'OF') {
          payload.add('0');
        } else if (categorySetting.value == 'ON') {
          payload.add('1');
        } else if (categorySetting.value.contains(":") ||
            categorySetting.value.contains(";")) {
          
          // Filter sub-values if this is a multi-value setting (e.g. Cyclic Timer motors)
          final visibleVals = _getVisibleValues(menuItemEntity, categorySetting, modelId);
          String combined = visibleVals.join(';');

          payload.add(combined
              .replaceAll(':', ',')
              .replaceAll(';', ',')
              .replaceAll(RegExp(r'\s+'), ''));
        } else if (categorySetting.widgetType == SettingWidgetType.phone) {
          print("categorySetting.value : ${categorySetting.value}");
          final phone = PhoneNumber.fromCompleteNumber(
              completeNumber: categorySetting.value);
          print("phone : $phone");
          payload.add(categorySetting.value.isEmpty
              ? ","
              : "+${phone.countryCode},${phone.number}");
          print("payload : ${payload}");
        } else {
          payload.add(categorySetting.value.toString());
        }
      }
    }
    kdebugmode('wlc payload: $payload');
    return payload.join(',');
  }

  List<String> _getVisibleValues(MenuItemEntity menu, SettingsEntity setting, int modelId) {
    if (!setting.value.contains(';')) {
       return [setting.value];
    }
    
    final titleParts = setting.title.trim().isEmpty ? <String>[] : setting.title.split(';').map((e) => e.trim()).toList();
    final valueParts = setting.value.trim().isEmpty ? <String>[] : setting.value.split(';').map((e) => e.trim()).toList();
    final hiddenParts = setting.hiddenFlag.trim().isEmpty ? <String>[] : setting.hiddenFlag.split(';').map((e) => e.trim()).toList();

    int maxCount = titleParts.length;
    if (valueParts.length > maxCount) maxCount = valueParts.length;
    if (hiddenParts.length > maxCount) maxCount = hiddenParts.length;

    bool isVisibleFlag(String flag) => flag.trim().isNotEmpty && flag.trim() != "0";
    
    if (menu.menu.menuSettingId == 505) {
      final combinedText = '${setting.title} ${setting.smsFormat}'.toLowerCase();
      if ((combinedText.contains('motor') || combinedText.contains('pump')) && maxCount > 1) {
        final fallbackFlag = isVisibleFlag(setting.hiddenFlag) ? "1" : "0";
        final hiddenFlags = List<String>.generate(maxCount, (index) {
          if (index < hiddenParts.length && hiddenParts[index].isNotEmpty) {
            return hiddenParts[index];
          }
          return fallbackFlag;
        });

        List<String> visibleValues = [];
        for (int i = 0; i < maxCount; i++) {
          if (i < hiddenFlags.length && isVisibleFlag(hiddenFlags[i])) {
             visibleValues.add(i < valueParts.length ? valueParts[i] : "");
          }
        }
        return visibleValues;
      }
    }
    
    return valueParts;
  }

  bool _isSettingVisible(MenuItemEntity menu, SettingsEntity setting, int modelId) {
    final titleParts = setting.title.trim().isEmpty ? <String>[] : setting.title.split(';').map((e) => e.trim()).toList();
    final valueParts = setting.value.trim().isEmpty ? <String>[] : setting.value.split(';').map((e) => e.trim()).toList();
    final hiddenParts = setting.hiddenFlag.trim().isEmpty ? <String>[] : setting.hiddenFlag.split(';').map((e) => e.trim()).toList();

    int maxCount = titleParts.length;
    if (valueParts.length > maxCount) maxCount = valueParts.length;
    if (hiddenParts.length > maxCount) maxCount = hiddenParts.length;

    bool isVisibleFlag(String flag) => flag.trim().isNotEmpty && flag.trim() != "0";

    if (menu.menu.menuSettingId == 505) {
      final combinedText = '${setting.title} ${setting.smsFormat}'.toLowerCase();
      if ((combinedText.contains('motor') || combinedText.contains('pump')) && maxCount > 1) {
        final fallbackFlag = isVisibleFlag(setting.hiddenFlag) ? "1" : "0";
        final hiddenFlags = List<String>.generate(maxCount, (index) {
          if (index < hiddenParts.length && hiddenParts[index].isNotEmpty) {
            return hiddenParts[index];
          }
          return fallbackFlag;
        });

        final visible = List.generate(maxCount, (i) => i).where((subIndex) {
          return subIndex < hiddenFlags.length && isVisibleFlag(hiddenFlags[subIndex]);
        }).toList();

        return visible.isNotEmpty;
      }
    }

    if (hiddenParts.isEmpty) {
      return isVisibleFlag(setting.hiddenFlag);
    }
    return hiddenParts.any(isVisibleFlag);
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

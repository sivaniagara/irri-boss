import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/action_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/leaf_box.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/retry.dart';
import 'package:niagara_smart_drip_irrigation/core/services/time_picker_service.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/setting_widget_type.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/pump_settings_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/widgets/setting_list_tile.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/custom_switch.dart';
import '../../../edit_program/presentation/widgets/custom_card.dart';
import '../../../sendrev_msg/utils/senrev_routes.dart';
import '../../domain/entities/template_json_entity.dart';
import '../../utils/pump_settings_images.dart';
import '../bloc/pump_setting_view_state.dart';
import '../bloc/pump_settings_state.dart';
import '../cubit/pump_settings_view_response_cubit.dart';

class PumpSettingsPage extends StatelessWidget {
  final int userId, subUserId, controllerId, menuId;
  final String? menuName;
  final String deviceId;
  final int modelId;

  const PumpSettingsPage({
    super.key,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.menuId,
    required this.deviceId,
    this.menuName,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<PumpSettingsCubit>()
        ..loadSettings(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
          menuId: menuId,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(menuName ?? 'Pump Settings'),
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.black,
          actions: [
            Builder(
              builder: (appBarContext) => IconButton(
                onPressed: () {
                  final cubit = appBarContext.read<PumpSettingsCubit>();
                  GlassyAlertDialog.show(
                    context: context,
                    title: "Hide/Show Settings",
                    content: BlocProvider<PumpSettingsCubit>.value(
                      value: cubit,
                      child: SizedBox(
                        width: double.maxFinite,
                        child: _HideShowSettingsDialog(
                          userId: userId,
                          subUserId: subUserId,
                          controllerId: controllerId,
                          modelId: modelId,
                        ),
                      ),
                    ),
                    actionsBuilder: (dialogContext) => [
                      ActionButton(
                        onPressed: () {
                          cubit.updateHiddenFlags(
                            userId: userId,
                            subUserId: subUserId,
                            controllerId: controllerId,
                            menuItemEntity:
                            (cubit.state as GetPumpSettingsLoaded).settings,
                            sentSms: "",
                          );
                          Navigator.pop(dialogContext);
                        },
                        isPrimary: true,
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
                icon: const Icon(Icons.settings_suggest_outlined),
              ),
            ),
            IconButton(
              onPressed: () {
                context.push(
                  SendRevPageRoutes.sendRevMsgPage,
                  extra: {
                    'userId': userId,
                    'controllerId': controllerId,
                    'subuserId': subUserId
                  },
                );
              },
              icon: const Icon(Icons.history_edu_outlined),
            )
          ],
        ),
        body: BlocListener<PumpSettingsCubit, PumpSettingsState>(
          listenWhen: (previous, current) =>
          current is SettingsSendStartedState ||
              current is SettingsSendSuccessState ||
              current is SettingsFailureState,
          listener: (context, state) {
            if (state is SettingsSendStartedState) {
              Fluttertoast.showToast(msg: "Sending...");
            } else if (state is SettingsSendSuccessState) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.green,
              );
            } else if (state is SettingsFailureState) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.red,
              );
            }
          },
          child: BlocBuilder<PumpSettingsCubit, PumpSettingsState>(
            buildWhen: (previous, current) =>
            current is GetPumpSettingsInitial ||
                current is GetPumpSettingsError ||
                current is GetPumpSettingsLoaded,
            builder: (context, state) {
              if (state is GetPumpSettingsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetPumpSettingsError) {
                return Center(
                  child: Retry(
                    message: state.message,
                    onPressed: () =>
                        context.read<PumpSettingsCubit>().loadSettings(
                          userId: userId,
                          subUserId: subUserId,
                          controllerId: controllerId,
                          menuId: menuId,
                        ),
                  ),
                );
              }
              final loadedState = state as GetPumpSettingsLoaded;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  children: [
                    if ([509, 511].contains(menuId))
                      BlocBuilder<PumpSettingsViewResponseCubit,
                          PumpSettingViewState>(
                        builder: (context, state) {
                          if (state is PumpSettingsViewReceived) {
                            return Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueAccent),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    _SettingsList(
                      menu: loadedState.settings,
                      deviceId: deviceId,
                      userId: userId,
                      controllerId: controllerId,
                      subUserId: subUserId,
                      modelId: modelId,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

List<String> _splitSettingParts(String rawValue) {
  if (rawValue.trim().isEmpty) return const [];
  return rawValue.split(';').map((e) => e.trim()).toList();
}

bool _isVisibleHiddenFlag(String flag) {
  return flag.trim().isNotEmpty && flag.trim() != "0";
}

int _timerMotorPartCount(SettingsEntity setting) {
  final titleCount = _splitSettingParts(setting.title).length;
  final valueCount = _splitSettingParts(setting.value).length;
  final hiddenCount = _splitSettingParts(setting.hiddenFlag).length;

  var maxCount = titleCount;
  if (valueCount > maxCount) maxCount = valueCount;
  if (hiddenCount > maxCount) maxCount = hiddenCount;
  return maxCount;
}

List<String> _timerMotorHiddenFlags(SettingsEntity setting) {
  final partCount = _timerMotorPartCount(setting);
  final rawHiddenFlags = _splitSettingParts(setting.hiddenFlag);
  final fallbackFlag = _isVisibleHiddenFlag(setting.hiddenFlag) ? "1" : "0";

  return List<String>.generate(partCount, (index) {
    if (index < rawHiddenFlags.length && rawHiddenFlags[index].isNotEmpty) {
      return rawHiddenFlags[index];
    }
    return fallbackFlag;
  });
}

String _timerMotorLabel(SettingsEntity setting, int subIndex) {
  final titles = _splitSettingParts(setting.title);
  if (subIndex < titles.length && titles[subIndex].isNotEmpty) {
    return titles[subIndex];
  }
  return 'Motor ${subIndex + 1}';
}

bool _supportsTimerMotorVisibility(
    MenuItemEntity menu, SettingsEntity setting) {
  // Broaden this to support any multi-part setting in the Timer Settings menu (505)
  if (menu.menu.menuSettingId != 505) return false;

  final combinedText = '${setting.title} ${setting.smsFormat}'.toLowerCase();
  // Ensure it's a motor/pump related setting and has multiple parts
  return (combinedText.contains('motor') || combinedText.contains('pump')) &&
      _timerMotorPartCount(setting) > 1;
}

List<int> _availableTimerMotorSubIndexes({
  required MenuItemEntity menu,
  required SettingsEntity setting,
  required int modelId,
}) {
  if (!_supportsTimerMotorVisibility(menu, setting)) return const [];
  // Return all sub-indexes so that Motor 1 and Motor 2 both show in the Hidden/Show dialog
  return List<int>.generate(_timerMotorPartCount(setting), (i) => i);
}

List<int> _visibleTimerMotorSubIndexes({
  required MenuItemEntity menu,
  required SettingsEntity setting,
  required int modelId,
}) {
  final hiddenFlags = _timerMotorHiddenFlags(setting);
  final available = _availableTimerMotorSubIndexes(
    menu: menu,
    setting: setting,
    modelId: modelId,
  );

  final visible = available.where((subIndex) {
    return subIndex < hiddenFlags.length &&
        _isVisibleHiddenFlag(hiddenFlags[subIndex]);
  }).toList(growable: false);

  if (AppConstants.isDoublePumpLive(modelId)) {
    return visible;
  }

  // For single pump, we only show one motor in the UI even if multiple are enabled in hidden settings.
  return visible.isEmpty ? const <int>[] : <int>[visible.first];
}

bool _isSettingVisible({
  required MenuItemEntity menu,
  required SettingsEntity setting,
  required int modelId,
}) {
  if (_supportsTimerMotorVisibility(menu, setting)) {
    return _visibleTimerMotorSubIndexes(
      menu: menu,
      setting: setting,
      modelId: modelId,
    ).isNotEmpty;
  }

  final hiddenFlags = _splitSettingParts(setting.hiddenFlag);
  if (hiddenFlags.isEmpty) {
    return _isVisibleHiddenFlag(setting.hiddenFlag);
  }
  return hiddenFlags.any(_isVisibleHiddenFlag);
}

class _HideShowSettingsDialog extends StatelessWidget {
  final int userId;
  final int subUserId;
  final int controllerId;
  final int modelId;

  const _HideShowSettingsDialog({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PumpSettingsCubit, PumpSettingsState>(
      buildWhen: (previous, current) => current is GetPumpSettingsLoaded,
      builder: (context, state) {
        if (state is! GetPumpSettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final menu = state.settings;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
            List.generate(menu.template.sections.length, (sectionIndex) {
              final section = menu.template.sections[sectionIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      section.sectionName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                  ...section.settings.asMap().entries.map((entry) {
                    final settingIndex = entry.key;
                    final setting = entry.value;

                    // Modification: Split labels with ';' into separate checklist items
                    final labelParts = _splitSettingParts(setting.title);
                    final isMultiPart = labelParts.length > 1;

                    if (isMultiPart ||
                        _supportsTimerMotorVisibility(menu, setting)) {
                      final hiddenFlags = _timerMotorHiddenFlags(setting);
                      final count = isMultiPart
                          ? labelParts.length
                          : _timerMotorPartCount(setting);

                      return Column(
                        children: List.generate(count, (subIndex) {
                          final label = subIndex < labelParts.length
                              ? labelParts[subIndex]
                              : 'Motor ${subIndex + 1}';
                          final isVisible = subIndex < hiddenFlags.length
                              ? _isVisibleHiddenFlag(hiddenFlags[subIndex])
                              : true;

                          return CheckboxListTile(
                            title: Text(label,
                                style: const TextStyle(fontSize: 14)),
                            value: isVisible,
                            dense: true,
                            onChanged: (bool? newValue) {
                              final updatedFlags =
                              List<String>.from(hiddenFlags);
                              while (updatedFlags.length <= subIndex) {
                                updatedFlags.add("1");
                              }
                              updatedFlags[subIndex] =
                              newValue == true ? "1" : "0";
                              context
                                  .read<PumpSettingsCubit>()
                                  .updateSettingValue(
                                updatedFlags.join(';'),
                                sectionIndex,
                                settingIndex,
                                menu,
                                isHiddenFlag: true,
                              );
                            },
                          );
                        }),
                      );
                    }

                    return CheckboxListTile(
                      title: Text(setting.title,
                          style: const TextStyle(fontSize: 14)),
                      value: setting.hiddenFlag == "1",
                      dense: true,
                      onChanged: (bool? newValue) {
                        context.read<PumpSettingsCubit>().updateSettingValue(
                          newValue == true ? "1" : "0",
                          sectionIndex,
                          settingIndex,
                          menu,
                          isHiddenFlag: true,
                        );
                      },
                    );
                  }),
                  if (sectionIndex < menu.template.sections.length - 1)
                    const Divider(),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _SettingsList extends StatelessWidget {
  final int userId, subUserId, controllerId;
  final int modelId;
  final MenuItemEntity menu;
  final String deviceId;

  const _SettingsList({
    required this.menu,
    required this.deviceId,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menu.template.sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = menu.template.sections[sectionIndex];
        final hasVisibleSetting = section.settings.asMap().entries.any((entry) {
          return _isSettingVisible(
            menu: menu,
            setting: entry.value,
            modelId: modelId,
          );
        });
        if (!hasVisibleSetting) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  section.sectionName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CustomCard(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemBuilder: (BuildContext context, int index) {
                    final setting = section.settings[index];
                    if (!_isSettingVisible(
                      menu: menu,
                      setting: setting,
                      modelId: modelId,
                    )) {
                      return const SizedBox();
                    }
                    return _SettingRow(
                      menuItemEntity: menu,
                      sectionIndex: sectionIndex,
                      settingIndex: index,
                      deviceId: deviceId,
                      userId: userId,
                      subUserId: subUserId,
                      controllerId: controllerId,
                      modelId: modelId,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    final setting = section.settings[index];
                    if (!_isSettingVisible(
                      menu: menu,
                      setting: setting,
                      modelId: modelId,
                    )) {
                      return const SizedBox();
                    }
                    if (setting.widgetType == SettingWidgetType.multiText) {
                      return const SizedBox.shrink();
                    }
                    return const Divider(thickness: 0.6);
                  },
                  itemCount: section.settings.length,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _SettingRow extends StatelessWidget {
  final int userId, subUserId, controllerId;
  final int modelId;
  final MenuItemEntity menuItemEntity;
  final int sectionIndex;
  final int settingIndex;
  final String deviceId;

  const _SettingRow({
    required this.menuItemEntity,
    required this.sectionIndex,
    required this.settingIndex,
    required this.deviceId,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.modelId,
  });

  static final _formKeys = <String, GlobalKey<FormState>>{};

  String get _formKeyId => '$sectionIndex-$settingIndex';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PumpSettingsCubit>();
    final formKey =
    _formKeys.putIfAbsent(_formKeyId, () => GlobalKey<FormState>());
    final setting =
    menuItemEntity.template.sections[sectionIndex].settings[settingIndex];

    final bool isSending = context.select((PumpSettingsCubit c) {
      final s = c.state;
      return s is SettingSendingState &&
          s.sectionIndex == sectionIndex &&
          s.settingIndex == settingIndex;
    });

    return Form(
      key: formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildInput(context)),
          const SizedBox(width: 8),
          _SendButton(
            isSending: isSending,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                cubit.sendCurrentSetting(
                  sectionIndex,
                  settingIndex,
                  deviceId,
                  userId,
                  subUserId,
                  controllerId,
                  menuItemEntity,
                );
                context.read<PumpSettingsViewResponseCubit>().clear();
              } else {
                Fluttertoast.showToast(msg: "Please correct the errors");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final section = menuItemEntity.template.sections[sectionIndex];
    final setting = section.settings[settingIndex];
    final path =
        '${menuItemEntity.menu.menuSettingId}_${section.typeId}_${setting.serialNumber}';
    final splitMotorVisibility =
    _supportsTimerMotorVisibility(menuItemEntity, setting);
    final visibleMotorIndexes = splitMotorVisibility
        ? _visibleTimerMotorSubIndexes(
      menu: menuItemEntity,
      setting: setting,
      modelId: modelId,
    )
        : const <int>[];

    return switch (setting.widgetType) {
      SettingWidgetType.phone =>
          _PhoneInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.multiTime => _MultiTimeInput(
        setting: setting,
        onChanged: _onChanged(context),
        visibleIndexes: splitMotorVisibility ? visibleMotorIndexes : null,
      ),
      SettingWidgetType.fullText => _TextInput(
        setting: setting,
        onChanged: _onChanged(context),
        label: setting.title,
        menuId: menuItemEntity.menu.menuSettingId,
        imagePath: ([508].contains(menuItemEntity.menu.menuSettingId) &&
            ![1, 2].contains(section.typeId))
            ? PumpSettingsImages.getCommunicationConfigIcons(path)
            : null,
      ),
      SettingWidgetType.multiText => ([
        "VOLTCAL",
        "VOLTAGCAL",
        "CURRCAL",
        "CURCAL",
        "CURRENTCAL"
      ].contains(setting.smsFormat.trim().toUpperCase()))
          ? _CalibrationInput(
          setting: setting, onChanged: _onChanged(context))
          : _MultiTextInput(
        setting: setting,
        onChanged: _onChanged(context),
        visibleIndexes:
        splitMotorVisibility ? visibleMotorIndexes : null,
      ),
      _ => SettingListTile(
        title: setting.title,
        leadingIcon: [509].contains(menuItemEntity.menu.menuSettingId)
            ? PumpSettingsImages.getStatusCheckIcons(path)
            : null,
        trailing: _buildTrailing(context),
        onTap: () => _handleTap(context),
      ),
    };
  }

  Widget _buildTrailing(BuildContext context) {
    final setting =
    menuItemEntity.template.sections[sectionIndex].settings[settingIndex];
    return switch (setting.widgetType) {
      SettingWidgetType.nothing => const SizedBox.shrink(),
      SettingWidgetType.text => SizedBox(
        width: 80,
        child: _TextInput(
          setting: setting,
          onChanged: _onChanged(context),
          menuId: menuItemEntity.menu.menuSettingId,
        ),
      ),
      SettingWidgetType.toggle => CustomSwitch(
        value: setting.value == "ON",
        onChanged: (_) =>
            _onChanged(context)(setting.value == "ON" ? "OF" : "ON"),
      ),
      SettingWidgetType.time => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          setting.value.isEmpty ? "00:00" : setting.value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      _ => Text(
        setting.value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    };
  }

  void Function(String) _onChanged(BuildContext context) {
    return (String newValue) {
      context.read<PumpSettingsCubit>().updateSettingValue(
        newValue,
        sectionIndex,
        settingIndex,
        menuItemEntity,
        userId: userId,
        subUserId: subUserId,
        controllerId: controllerId,
      );
    };
  }

  void _handleTap(BuildContext context) async {
    String? newValue;
    final setting =
    menuItemEntity.template.sections[sectionIndex].settings[settingIndex];

    switch (setting.widgetType) {
      case SettingWidgetType.toggle:
        newValue = setting.value == "OF" ? "ON" : "OF";
        break;

      case SettingWidgetType.time:
        newValue = await TimePickerService.show(
          context: context,
          title: setting.title,
          initialTime: setting.value,
        );
        break;

      default:
        return;
    }

    if (newValue != null && newValue != setting.value) {
      _onChanged(context)(newValue);
    }
  }
}

class _SendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onPressed;

  const _SendButton({required this.isSending, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: isSending
          ? const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          'assets/images/icons/send_icon.png',
          width: 25,
        ),
      ),
      onPressed: isSending ? null : onPressed,
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;

  const _PhoneInput({required this.setting, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: IntlPhoneField(
        initialValue: setting.value.isNotEmpty ? setting.value : null,
        initialCountryCode: 'IN',
        decoration: InputDecoration(
          labelText: setting.title,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (phone) => onChanged(phone.completeNumber),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? imagePath;
  final int menuId;

  const _TextInput({
    required this.setting,
    required this.onChanged,
    this.label,
    this.imagePath,
    required this.menuId,
  });

  @override
  Widget build(BuildContext context) {
    final isTextOnly = menuId == 508;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LeafBox(
          height: isTextOnly ? 35 : 30,
          padding: EdgeInsets.zero,
          margin: isTextOnly
              ? const EdgeInsets.symmetric(horizontal: 5, vertical: 5)
              : EdgeInsets.zero,
          child: TextFormField(
            initialValue: setting.value,
            keyboardType: !isTextOnly
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            textAlign: isTextOnly ? TextAlign.start : TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            inputFormatters: !isTextOnly
                ? [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,9}')),
              LengthLimitingTextInputFormatter(5),
            ]
                : null,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Required';
              return null;
            },
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: imagePath != null
                  ? Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(imagePath!, width: 20),
              )
                  : null,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _MultiTimeInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  final List<int>? visibleIndexes;

  const _MultiTimeInput({
    required this.setting,
    required this.onChanged,
    this.visibleIndexes,
  });

  @override
  Widget build(BuildContext context) {
    final titles = _splitSettingParts(setting.title);
    final values = _splitSettingParts(setting.value);
    final indexes =
        visibleIndexes ?? List<int>.generate(titles.length, (i) => i);

    return Column(
      children: List.generate(
        indexes.length,
            (visibleIndex) {
          final i = indexes[visibleIndex];
          final title = i < titles.length && titles[i].isNotEmpty
              ? titles[i]
              : 'Motor ${i + 1}';
          return SettingListTile(
            title: title,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                i < values.length && values[i].isNotEmpty ? values[i] : "00:00",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () async {
              final newTime = await TimePickerService.show(
                context: context,
                title: title,
                initialTime: i < values.length ? values[i] : "00:00",
              );
              if (newTime != null) {
                final newValues = List<String>.from(values);
                while (newValues.length <= i) {
                  newValues.add("");
                }
                newValues[i] = newTime;
                onChanged(newValues.join(';'));
              }
            },
          );
        },
      ),
    );
  }
}

class _CalibrationInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;

  const _CalibrationInput({required this.setting, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final rawTitles = setting.title.split(';').map((e) => e.trim()).toList();
    final rawValues = setting.value.split(';').map((e) => e.trim()).toList();

    final titles = List<String>.generate(3, (i) {
      if (i < rawTitles.length && rawTitles[i].isNotEmpty) return rawTitles[i];
      return i == 0 ? "VR" : (i == 1 ? "VY" : "VB");
    });

    final values = List<String>.generate(3, (i) {
      if (i < rawValues.length) return rawValues[i];
      return "0";
    });

    final String format = setting.smsFormat.trim().toUpperCase();
    final bool isVoltageCal = format == "VOLTCAL";
    final bool isVoltageWhole = format == "VOLTAGCAL";
    final bool isCurrentCal = format == "CURRCAL" || format == "CURCAL";
    final bool isCurrentSecondRow = format == "CURRENTCAL";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            children: titles
                .map((t) => Expanded(
              child: Text(
                t,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ))
                .toList(),
          ),
        ),
        Row(
          children: List.generate(
            3,
                (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: LeafBox(
                  height: 36,
                  padding: EdgeInsets.zero,
                  child: TextFormField(
                    initialValue: i < values.length ? values[i] : "0",
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: isVoltageWhole
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isVoltageCal
                          ? "0.0000"
                          : (isCurrentCal
                          ? "0.00000"
                          : (isVoltageWhole
                          ? "000"
                          : (isCurrentSecondRow ? "0.00" : "0.0000"))),
                      hintStyle:
                      const TextStyle(fontSize: 10, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (newValue) {
                      final newValues = List<String>.from(values);
                      newValues[i] = newValue.trim();
                      onChanged(newValues.join(';'));
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _MultiTextInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  final List<int>? visibleIndexes;

  const _MultiTextInput({
    required this.setting,
    required this.onChanged,
    this.visibleIndexes,
  });

  @override
  Widget build(BuildContext context) {
    final titles = _splitSettingParts(setting.title);
    final values = _splitSettingParts(setting.value);
    final itemCount =
    titles.length > values.length ? titles.length : values.length;
    final indexes = visibleIndexes ?? List<int>.generate(itemCount, (i) => i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (indexes.any((i) => i < titles.length && titles[i].isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              children: indexes
                  .map((i) => Expanded(
                child: Text(
                  i < titles.length && titles[i].isNotEmpty
                      ? titles[i]
                      : 'Motor ${i + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ))
                  .toList(),
            ),
          ),
        Row(
          children: List.generate(
            indexes.length,
                (visibleIndex) {
              final i = indexes[visibleIndex];
              final initialValue = i < values.length ? values[i] : '';
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: LeafBox(
                    height: 36,
                    padding: EdgeInsets.zero,
                    child: TextFormField(
                      initialValue: initialValue,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (newValue) {
                        final newValues = List<String>.from(values);
                        while (newValues.length <= i) {
                          newValues.add("");
                        }
                        newValues[i] = newValue;
                        onChanged(newValues.join(';'));
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

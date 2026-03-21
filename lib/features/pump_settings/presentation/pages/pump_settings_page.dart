import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/action_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_card.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/retry.dart';
import 'package:niagara_smart_drip_irrigation/core/services/time_picker_service.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/setting_widget_type.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/pump_settings_view_response_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/pump_settings_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/widgets/setting_list_tile.dart';

import '../../../../core/di/injection.dart' as di;
import '../../../sendrev_msg/utils/senrev_routes.dart';
import '../../domain/entities/template_json_entity.dart';
import '../bloc/pump_setting_view_state.dart';
import '../bloc/pump_settings_state.dart';

class PumpSettingsPage extends StatelessWidget {
  final int userId, subUserId, controllerId, menuId, modelId;
  final String? menuName;
  final String deviceId;

  const PumpSettingsPage({
    super.key,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.menuId,
    required this.modelId,
    required this.deviceId,
    this.menuName,
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
        appBar: CustomAppBar(
          title: menuName ?? 'Pump Settings',
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
                      child: _HideShowSettingsDialog(),
                    ),
                    actions: [
                      ActionButton(
                        onPressed: () {
                          cubit.updateHiddenFlags(
                              userId: userId,
                              subUserId: subUserId,
                              controllerId: controllerId,
                              menuItemEntity: (cubit.state as GetPumpSettingsLoaded).settings,
                              sentSms: "Hidden flag updated"
                          );
                          Navigator.of(appBarContext).pop();
                        },
                        isPrimary: true,
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
                icon: const Icon(Icons.hide_source, color: Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                context.push(
                  SendRevPageRoutes.sendRevMsgPage,
                  extra: {'userId': userId, 'controllerId': controllerId, 'subuserId': subUserId},
                );
              },
              icon: const Icon(Icons.message, color: Colors.black),
            )
          ],
        ),
        body: BlocListener<PumpSettingsCubit, PumpSettingsState>(
          listenWhen: (previous, current) => current is SettingsSendStartedState
              || current is SettingsSendSuccessState
              || current is SettingsFailureState,
          listener: (context, state) {
            if (state is SettingsSendStartedState) {
              Fluttertoast.showToast(
                msg: "Sending...",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[800],
              );
            } else if (state is SettingsSendSuccessState) {
              Fluttertoast.showToast(
                msg: state.message,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Theme.of(context).primaryColor,
              );
            } else if (state is SettingsFailureState) {
              Fluttertoast.showToast(
                msg: state.message,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
              );
            }
          },
          child: BlocBuilder<PumpSettingsCubit, PumpSettingsState>(
            buildWhen: (previous, current) {
              return current is GetPumpSettingsInitial ||
                  current is GetPumpSettingsError ||
                  current is GetPumpSettingsLoaded;
            },
            builder: (context, state) {
              if (state is GetPumpSettingsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetPumpSettingsError) {
                return Center(
                  child: Retry(
                    message: state.message,
                    onPressed: () => context.read<PumpSettingsCubit>()
                        .loadSettings(
                        userId: userId,
                        subUserId: subUserId,
                        controllerId: controllerId,
                        menuId: menuId
                    ),
                  ),
                );
              }
              final loadedState = state as GetPumpSettingsLoaded;
              return Column(
                children: [
                  if ([509, 511].contains(menuId))
                    BlocBuilder<PumpSettingsViewResponseCubit, PumpSettingViewState>(
                      builder: (context, state) {
                        if (state is PumpSettingsViewReceived) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: CustomCard(
                              child: Text(state.message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  Expanded(
                    child: _SettingsList(
                      menu: loadedState.settings,
                      deviceId: deviceId,
                      userId: userId,
                      controllerId: controllerId,
                      subUserId: subUserId,
                      modelId: modelId,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HideShowSettingsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PumpSettingsCubit, PumpSettingsState>(
      buildWhen: (previous, current) => current is GetPumpSettingsLoaded,
      builder: (context, state) {
        if (state is! GetPumpSettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final menu = state.settings;
        return ListView.builder(
          itemCount: menu.template.sections.length,
          itemBuilder: (context, sectionIndex) {
            final section = menu.template.sections[sectionIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    section.sectionName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                ...section.settings.map((setting) {
                  final settingIndex = section.settings.indexOf(setting);
                  final titles = setting.title.split(';');
                  final flags = setting.hiddenFlag.split(';');

                  // Ensure we have a flag for every title, default to "1" (visible)
                  final actualFlags = List.generate(titles.length, (i) => i < flags.length ? flags[i] : "1");

                  if (titles.length > 1) {
                    // It's a multi-item setting like Motor 1; Motor 2
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(titles.length, (subIndex) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text(titles[subIndex].trim(), style: const TextStyle(fontSize: 14)),
                            value: actualFlags[subIndex] == "1",
                            onChanged: (bool? newValue) {
                              actualFlags[subIndex] = (newValue == true) ? "1" : "0";
                              context.read<PumpSettingsCubit>().updateSettingValue(
                                actualFlags.join(';'),
                                sectionIndex,
                                settingIndex,
                                menu,
                                isHiddenFlag: true,
                              );
                            },
                          );
                        }),
                        const Divider(indent: 16, endIndent: 16),
                      ],
                    );
                  } else {
                    // Single item setting
                    return CheckboxListTile(
                      dense: true,
                      title: Text(setting.title.trim(), style: const TextStyle(fontSize: 14)),
                      value: actualFlags[0] == "1",
                      onChanged: (bool? newValue) {
                        actualFlags[0] = (newValue == true) ? "1" : "0";
                        context.read<PumpSettingsCubit>().updateSettingValue(
                          actualFlags.join(';'),
                          sectionIndex,
                          settingIndex,
                          menu,
                          isHiddenFlag: true,
                        );
                      },
                    );
                  }
                }),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettingsList extends StatelessWidget {
  final int userId, subUserId, controllerId, modelId;
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
    bool isDoublePumpByModel = modelId == 27;
    String pumpModeValue = "SINGLE";

    for (var section in menu.template.sections) {
      for (var setting in section.settings) {
        final title = setting.title.toUpperCase();
        if (title.contains("DUAL PUMP") || title.contains("PUMP COUNT")) {
          pumpModeValue = setting.value.trim().toUpperCase();
          break;
        }
      }
    }

    bool isSinglePump = !isDoublePumpByModel;
    if (pumpModeValue == "DOUBLE" || pumpModeValue == "ON" || pumpModeValue == "2") {
      isSinglePump = false;
    }

    return ListView.builder(
      itemCount: menu.template.sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = menu.template.sections[sectionIndex];

        bool sectionHasVisibleItems = false;
        for (var s in section.settings) {
          final titles = s.title.split(';');
          final flags = s.hiddenFlag.split(';');

          for (int i = 0; i < titles.length; i++) {
            final t = titles[i].toUpperCase();
            final f = i < flags.length ? flags[i] : "1";

            bool isMotor2 = t.contains("MOTOR 2") || t.contains("PUMP 2") || t.contains("MOTOR2") || t.contains("PUMP2");
            bool isFilteredByPumpMode = isSinglePump && isMotor2;

            // Item is visible if NOT filtered by single-pump mode AND NOT hidden by user
            if (!isFilteredByPumpMode && f != "0") {
              sectionHasVisibleItems = true;
              break;
            }
          }
          if (sectionHasVisibleItems) break;
        }

        if (!sectionHasVisibleItems) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                section.sectionName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              CustomCard(
                child: Builder(
                  builder: (context) {
                    return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final setting = section.settings[index];

                          // Hide whole row if all its sub-items are suppressed
                          final titles = setting.title.split(';');
                          final flags = setting.hiddenFlag.split(';');
                          bool rowHasVisibleSubItems = false;
                          for (int i = 0; i < titles.length; i++) {
                            final t = titles[i].toUpperCase();
                            final f = i < flags.length ? flags[i] : "1";
                            bool isMotor2 = t.contains("MOTOR 2") || t.contains("PUMP 2") || t.contains("MOTOR2") || t.contains("PUMP2");
                            if (!(isSinglePump && isMotor2) && f != "0") {
                              rowHasVisibleSubItems = true;
                              break;
                            }
                          }

                          if (!rowHasVisibleSubItems) return const SizedBox.shrink();

                          return _SettingRow(
                            menuItemEntity: menu,
                            sectionIndex: sectionIndex,
                            settingIndex: index,
                            deviceId: deviceId,
                            userId: userId,
                            subUserId: subUserId,
                            controllerId: controllerId,
                            isSinglePump: isSinglePump,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          final setting = section.settings[index];
                          final nextSetting = index + 1 < section.settings.length ? section.settings[index+1] : null;

                          // Logic to hide divider if current row is hidden
                          final titles = setting.title.split(';');
                          final flags = setting.hiddenFlag.split(';');
                          bool currentRowVisible = false;
                          for (int i = 0; i < titles.length; i++) {
                            final t = titles[i].toUpperCase();
                            final f = i < flags.length ? flags[i] : "1";
                            bool isMotor2 = t.contains("MOTOR 2") || t.contains("PUMP 2");
                            if (!(isSinglePump && isMotor2) && f != "0") { currentRowVisible = true; break; }
                          }
                          if (!currentRowVisible) return const SizedBox.shrink();

                          // Logic to hide divider if next row is hidden
                          if (nextSetting != null) {
                            final nTitles = nextSetting.title.split(';');
                            final nFlags = nextSetting.hiddenFlag.split(';');
                            bool nextRowVisible = false;
                            for (int i = 0; i < nTitles.length; i++) {
                              final nt = nTitles[i].toUpperCase();
                              final nf = i < nFlags.length ? nFlags[i] : "1";
                              bool nisMotor2 = nt.contains("MOTOR 2") || nt.contains("PUMP 2");
                              if (!(isSinglePump && nisMotor2) && nf != "0") { nextRowVisible = true; break; }
                            }
                            if (!nextRowVisible) return const SizedBox.shrink();
                          }

                          if (section.settings[index].widgetType != SettingWidgetType.multiText) {
                            return const Divider(thickness: 0.6);
                          } else {
                            return const SizedBox(height: 12);
                          }
                        },
                        itemCount: section.settings.length
                    );
                  },
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
  final MenuItemEntity menuItemEntity;
  final int sectionIndex;
  final int settingIndex;
  final String deviceId;
  final bool isSinglePump;

  const _SettingRow({
    super.key,
    required this.menuItemEntity,
    required this.sectionIndex,
    required this.settingIndex,
    required this.deviceId,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.isSinglePump,
  });

  static final _formKeys = <String, GlobalKey<FormState>>{};

  String get _formKeyId => '$sectionIndex-$settingIndex';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PumpSettingsCubit>();
    final formKey = _formKeys.putIfAbsent(_formKeyId, () => GlobalKey<FormState>());

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildInput(context)),
            const SizedBox(width: 8),
            IconButton(
              padding: EdgeInsets.zero,
              icon: context.watch<PumpSettingsCubit>().state is SettingsSendStartedState
                  ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
                  : CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
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
                  Fluttertoast.showToast(
                    msg: "Please correct the highlighted fields",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.orange[800],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final setting = menuItemEntity.template.sections[sectionIndex].settings[settingIndex];
    return switch (setting.widgetType) {
      SettingWidgetType.phone => _PhoneInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.multiTime => _MultiTimeInput(setting: setting, onChanged: _onChanged(context), isSinglePump: isSinglePump),
      SettingWidgetType.fullText => _TextInput(
        key: ValueKey(setting.value), // 👈 Force rebuild on value change
        setting: setting,
        onChanged: _onChanged(context),
        label: setting.title,
        menuId: menuItemEntity.menu.menuSettingId,
      ),
      SettingWidgetType.multiText => _MultiTextInput(setting: setting, onChanged: _onChanged(context), isSinglePump: isSinglePump),
      _ => _navigationRow(
        context,
        title: setting.title,
        trailing: _buildTrailing(context),
        onTap: () => _handleTap(context),
      ),
    };
  }

  Widget _buildTrailing(BuildContext context) {
    final setting = menuItemEntity.template.sections[sectionIndex].settings[settingIndex];
    return switch (setting.widgetType) {
      SettingWidgetType.nothing => const SizedBox.shrink(),
      SettingWidgetType.text => SizedBox(
        width: 100,
        child: _TextInput(
          key: ValueKey(setting.value), // 👈 Force rebuild on value change
          setting: setting,
          onChanged: _onChanged(context),
          menuId: menuItemEntity.menu.menuSettingId,
        ),
      ),
      SettingWidgetType.toggle => Switch(
        value: setting.value == "ON",
        onChanged: (_) => _onChanged(context)(setting.value == "ON" ? "OF" : "ON"),
      ),
      SettingWidgetType.time => Text(
          setting.value.trim().isEmpty ? "00:00" : setting.value.trim(),
          style: Theme.of(context).textTheme.bodyMedium
      ),
      _ => Text(setting.value.trim(), style: Theme.of(context).textTheme.bodyMedium),
    };
  }

  void Function(String) _onChanged(BuildContext context) {
    return (String newValue) {
      context.read<PumpSettingsCubit>().updateSettingValue(
        newValue,
        sectionIndex,
        settingIndex,
        menuItemEntity,
      );
    };
  }

  void _handleTap(BuildContext context) async {
    String? newValue;
    final setting = menuItemEntity.template.sections[sectionIndex].settings[settingIndex];

    switch (setting.widgetType) {
      case SettingWidgetType.toggle:
        newValue = setting.value == "OF" ? "ON" : "OF";
        break;

      case SettingWidgetType.time:
        newValue = await TimePickerService.show(
          context: context,
          title: setting.title,
          initialTime: setting.value.trim(),
        );
        break;

      default:
        return;
    }

    if (newValue != null && newValue != setting.value) {
      _onChanged(context)(newValue);
    }
  }

  Widget _navigationRow(BuildContext context, {required String title, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            if (trailing != null) trailing else const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 14,),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IntlPhoneField(
        key: ValueKey(setting.value), // 👈 Force rebuild on value change
        initialValue: setting.value.trim().isNotEmpty ? setting.value.trim() : null,
        initialCountryCode: 'IN',
        validator: (phone) {
          if (phone == null || phone.completeNumber.isEmpty) {
            return 'Phone number is required';
          }
          if (phone.completeNumber.length < 10) {
            return 'Invalid phone number';
          }
          return null;
        },
        onChanged: (phone) => onChanged(phone.completeNumber),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  final String? label;
  final int menuId;

  const _TextInput({
    super.key, // 👈 Important to pass key
    required this.setting,
    required this.onChanged,
    this.label,
    required this.menuId,
  });

  @override
  Widget build(BuildContext context) {
    final isTextOnly = menuId == 508;

    return TextFormField(
      initialValue: setting.value.trim(),
      keyboardType: !isTextOnly ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      textAlign: isTextOnly ? TextAlign.start : TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      inputFormatters: !isTextOnly
          ? [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(10),
      ]
          : null,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Req';
        if (!isTextOnly) {
          final num = double.tryParse(value.trim());
          if (num == null) return 'Invalid';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
        errorStyle: const TextStyle(height: 0, fontSize: 0),
      ),
      onChanged: (val) => onChanged(val.trim()),
    );
  }
}

class _MultiTimeInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  final bool isSinglePump;

  const _MultiTimeInput({required this.setting, required this.onChanged, required this.isSinglePump});

  @override
  Widget build(BuildContext context) {
    final titles = setting.title.split(';').map((e) => e.trim()).toList();
    final rawValues = setting.value.split(';').map((e) => e.trim()).toList();
    final flags = setting.hiddenFlag.split(';');

    final hasSeconds = rawValues.any((v) => v.split(':').length > 2);
    final defaultTime = hasSeconds ? "00:00:00" : "00:00";

    final values = List<String>.generate(titles.length, (index) {
      if (index < rawValues.length && rawValues[index].isNotEmpty) {
        return rawValues[index];
      }
      return defaultTime;
    });

    final List<int> filteredIndices = [];
    for (int i = 0; i < titles.length; i++) {
      final t = titles[i].toUpperCase();
      final f = i < flags.length ? flags[i] : "1";
      bool isMotor2 = t.contains("MOTOR 2") || t.contains("PUMP 2") || t.contains(" M2") || t.contains(" P2");

      // Filter based on both Single Pump configuration AND manual hide/show flags
      if (!(isSinglePump && isMotor2) && f != "0") {
        filteredIndices.add(i);
      }
    }

    return Column(
      children: filteredIndices.map((i) => _navigationRow(
        context,
        key: ValueKey(values[i]), // 👈 Force rebuild on value change
        title: titles[i],
        trailing: Text(
          values[i],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        onTap: () async {
          final newTime = await TimePickerService.show(
            context: context,
            title: titles[i],
            initialTime: values[i],
          );
          if (newTime != null) {
            final newValues = List<String>.from(values);
            newValues[i] = newTime;
            onChanged(newValues.join(';'));
          }
        },
      )).toList(),
    );
  }

  Widget _navigationRow(BuildContext context, {Key? key, required String title, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            if (trailing != null) trailing else const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 14,),
          ],
        ),
      ),
    );
  }
}

class _MultiTextInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  final bool isSinglePump;

  const _MultiTextInput({required this.setting, required this.onChanged, required this.isSinglePump});

  @override
  Widget build(BuildContext context) {
    var rawTitles = setting.title.split(';').map((e) => e.trim()).toList();
    var rawValues = setting.value.split(';').map((e) => e.trim()).toList();
    final flags = setting.hiddenFlag.split(';');

    final String format = setting.smsFormat.trim().toUpperCase();
    final bool isVoltageCal = format == "VOLTCAL";
    final bool isVoltageWhole = format == "VOLTAGCAL";
    final bool isCurrentCal = format == "CURRCAL" || format == "CURCAL";
    final bool isCurrentSecondRow = format == "CURRENTCAL";
    final bool isDecimalOnlyLine = isVoltageCal || isCurrentCal;

    // Fix: Force 3 fields for Voltage and Current calibration second rows
    if ((isVoltageWhole || isCurrentSecondRow) && rawTitles.length < 3) {
      while (rawTitles.length < 3) rawTitles.add("");
      while (rawValues.length < 3) rawValues.add(rawValues.isNotEmpty ? rawValues[0] : "0");
    }

    final List<int> filteredIndices = [];
    for (int i = 0; i < rawTitles.length; i++) {
      final t = rawTitles[i].toUpperCase();
      final f = i < flags.length ? flags[i] : "1";
      bool isMotor2 = t.contains("MOTOR 2") || t.contains("PUMP 2") || t.contains(" M2") || t.contains(" P2");

      if (!(isSinglePump && isMotor2) && f != "0") {
        filteredIndices.add(i);
      }
    }

    final titles = filteredIndices.map((i) => rawTitles[i]).toList();
    final values = filteredIndices.map((i) => i < rawValues.length ? rawValues[i] : "0").toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titles.any((t) => t.isNotEmpty))
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              children: titles.map((t) => Expanded(
                child: Text(
                  t,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              )).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              titles.length,
                  (index) {
                final i = filteredIndices[index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: TextFormField(
                      key: ValueKey(values[index]), // 👈 Force rebuild on value change
                      initialValue: index < values.length ? values[index] : "0",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: isVoltageWhole
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: isVoltageCal ? "0.0000" : (isCurrentCal ? "0.00000" : (isVoltageWhole ? "000" : (isCurrentSecondRow ? "0.00" : null))),
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Req';
                        final numValue = double.tryParse(val.trim());
                        if (numValue == null) return 'Err';

                        if (isDecimalOnlyLine) {
                          if (!val.contains('.')) {
                            Fluttertoast.showToast(
                              msg: "Please Enter Decimal Values",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red[800],
                            );
                            return 'Dec';
                          }
                        } else if (isVoltageWhole) {
                          if (val.contains('.')) return 'Int';
                        } else if (isCurrentSecondRow) {
                          if (val.contains('.')) {
                            final parts = val.split('.');
                            if (parts.length > 2 || parts[1].length > 2) {
                              return 'Max 2 decimals';
                            }
                          }
                        }

                        if (numValue <= 0) return '>0';
                        return null;
                      },
                      onChanged: (newValue) {
                        final newRawValues = List<String>.from(rawValues);
                        if (i < newRawValues.length) {
                          newRawValues[i] = newValue.trim();
                        } else {
                          while (newRawValues.length <= i) {
                            newRawValues.add("0");
                          }
                          newRawValues[i] = newValue.trim();
                        }
                        onChanged(newRawValues.join(';'));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

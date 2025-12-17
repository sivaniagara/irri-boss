import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/action_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/retry.dart';
import 'package:niagara_smart_drip_irrigation/core/services/time_picker_service.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/pump_settings_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/widgets/setting_list_tile.dart';

import '../../../../core/di/injection.dart' as di;
import '../../domain/entities/setting_widget_type.dart';
import '../../domain/entities/template_json_entity.dart';
import '../bloc/pump_settings_state.dart';

class PumpSettingsPage extends StatelessWidget {
  final int userId, subUserId, controllerId, menuId;
  final String? menuName;
  final String deviceId;

  const PumpSettingsPage({
    super.key,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.menuId,
    required this.deviceId,
    this.menuName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => di.sl<PumpSettingsCubit>()
          ..loadSettings(userId: userId, subUserId: subUserId, controllerId: controllerId, menuId: menuId,),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(menuName ?? 'Pump Settings'),
          actions: [
            IconButton(
              onPressed: () {
                GlassyAlertDialog.show(
                  context: context,
                  title: "Hide/Show Settings",
                  content: BlocProvider<PumpSettingsCubit>.value(
                    value: context.read<PumpSettingsCubit>(),
                    child: _HideShowSettingsDialog(),
                  ),
                  actions: [
                    ActionButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
              icon: const Icon(Icons.hide_source),
            ),
          ],
        ),
        body: GlassyWrapper(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (n) {
              n.disallowIndicator();
              return true;
            },
            child: BlocBuilder<PumpSettingsCubit, PumpSettingsState>(
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
                return _SettingsList(
                  menu: (state as GetPumpSettingsLoaded).settings,
                  deviceId: deviceId,
                );
              },
            ),
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(section.sectionName, style: Theme.of(context).textTheme.titleMedium),
                ),
                ...section.settings.map((setting) {
                  final settingIndex = section.settings.indexOf(setting);
                  return CheckboxListTile(
                    title: Text(setting.title),
                    value: setting.hiddenFlag == "1",
                    onChanged: (bool? newValue) {
                      context.read<PumpSettingsCubit>().updateSettingValue(
                        newValue == true ? "1" : "0",
                        sectionIndex,
                        settingIndex,
                        isHiddenFlag: true,
                      );
                    },
                  );
                }),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettingsList extends StatelessWidget {
  final MenuItemEntity menu;
  final String deviceId;
  const _SettingsList({
    required this.menu,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: menu.template.sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = menu.template.sections[sectionIndex];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(section.sectionName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GlassCard(
                margin: EdgeInsetsGeometry.symmetric(horizontal: 0),
                padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
                child: Builder(
                  builder: (context) {
                    return ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          if(section.settings[index].hiddenFlag == "0") return SizedBox();
                          return _SettingRow(
                            setting: section.settings[index],
                            sectionIndex: sectionIndex,
                            settingIndex: index,
                            deviceId: deviceId,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          if (section.settings[index].widgetType != SettingWidgetType.multiText) {
                            if(section.settings[index].hiddenFlag == "0" && section.settings.where((e) => e.hiddenFlag == "1").length != index) return SizedBox();
                            return Divider(color: Colors.white54);
                          } else {
                            return Container();
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
  final SettingsEntity setting;
  final int sectionIndex;
  final int settingIndex;
  final String deviceId;

  const _SettingRow({
    required this.setting,
    required this.sectionIndex,
    required this.settingIndex,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PumpSettingsCubit>();

    return Row(
      children: [
        Expanded(child: _buildInput(context)),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: () => cubit.sendCurrentSetting(sectionIndex, settingIndex, deviceId),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    return switch (setting.widgetType) {
      SettingWidgetType.phone => _PhoneInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.multiTime => _MultiTimeInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.fullText => _TextInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.multiText => _MultiTextInput(setting: setting, onChanged: _onChanged(context)),
      _ => SettingListTile(
        title: setting.title,
        trailing: _buildTrailing(context),
        onTap: () => _handleTap(context),
      ),
    };
  }

  Widget _buildTrailing(BuildContext context) {
    return switch (setting.widgetType) {
    // SettingWidgetType.text => Text(setting.value.isEmpty ? "-" : setting.value, style: Theme.of(context).textTheme.bodyMedium,),
      SettingWidgetType.text => _TextInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.toggle => Switch(
        value: setting.value == "ON",
        onChanged: (_) => _onChanged(context)(setting.value == "ON" ? "OF" : "ON"),
      ),
      SettingWidgetType.time => Text(
          setting.value.isEmpty ? "00:00" : setting.value,
          style: Theme.of(context).textTheme.bodyMedium
      ),
      _ => Text(setting.value, style: Theme.of(context).textTheme.bodyMedium),
    };
  }

  void Function(String newValue) _onChanged(BuildContext context) {
    return (String newValue) {
      context.read<PumpSettingsCubit>().updateSettingValue(newValue, sectionIndex, settingIndex,);
    };
  }

  void _handleTap(BuildContext context) async {
    String? newValue;

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

class _PhoneInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  const _PhoneInput({required this.setting, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IntlPhoneField(
        initialValue: setting.value,
        initialCountryCode: 'IN',
        style: const TextStyle(color: Colors.white),
        dropdownTextStyle: const TextStyle(color: Colors.white),
        dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        onChanged: (phone) => onChanged(phone.completeNumber),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  const _TextInput({required this.setting, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: setting.value,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: setting.title,
            contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 10)),
        onChanged: onChanged,
      ),
    );
  }
}

class _MultiTimeInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  const _MultiTimeInput({required this.setting, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final titles = setting.title.split(';').map((e) => e.trim()).toList();
    final values = setting.value.split(';').map((e) => e.trim()).toList();

    return Column(
      children: List.generate(
          titles.length,
              (i) => SettingListTile(
            title: titles[i],
            trailing: Text(
              values[i],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () async {
              final newTime = await TimePickerService.show(
                  context: context,
                  title: titles[i],
                  initialTime: values[i]);
              if (newTime != null) {
                final newValues = [...values]..[i] = newTime;
                onChanged(newValues.join(';'));
              }
            },
          )),
    );
  }
}

class _MultiTextInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  const _MultiTextInput({required this.setting, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final titles = setting.title.split(';').map((e) => e.trim()).toList();
    final values = setting.value.split(';').map((e) => e.trim()).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 30,
            children: [
              for (int i = 0; i < titles.length; i++)
                if (titles[i].isNotEmpty)
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(titles[i]),
                  )
            ],
          ),
          // if(setting.title.isEmpty)
          Row(
            spacing: 30,
            children: [
              for (int i = 0; i < values.length; i++)
                Flexible(
                  child: TextFormField(
                    initialValue: values[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsetsGeometry.symmetric(
                            horizontal: 10, vertical: 0),
                        isDense: true),
                    onChanged: (newValue) async {
                      final newValues = [...values]..[i] = newValue;
                      onChanged(newValues.join(';'));
                    },
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}

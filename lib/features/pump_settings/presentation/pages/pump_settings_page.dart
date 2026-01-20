import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/action_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/leaf_box.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/retry.dart';
import 'package:niagara_smart_drip_irrigation/core/services/time_picker_service.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/setting_widget_type.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/pump_settings_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/widgets/setting_list_tile.dart';

import '../../../../core/di/injection.dart' as di;
import '../../../../core/widgets/custom_switch.dart';
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
        ..loadSettings(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
          menuId: menuId,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(menuName ?? 'Pump Settings'),
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
                              sentSms: ""
                          );
                          Navigator.of(appBarContext).pop();
                        },
                        isPrimary: true,
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
                icon: const Icon(Icons.hide_source),
              ),
            ),
            IconButton(
              onPressed: () {
                context.push(SendRevPageRoutes.sendRevMsgPage, extra: {'userId': userId, 'controllerId': controllerId, 'subuserId': subUserId});
              },
              icon: Icon(Icons.message),
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
              // print("previous :: $previous");
              // print("current :: $current");
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
                  if(menuId == 511)
                    BlocBuilder<PumpSettingsViewResponseCubit, PumpSettingViewState>(
                      builder: (context, state) {
                        if (state is PumpSettingsViewReceived) {
                          return GlassCard(
                              margin: EdgeInsetsGeometry.symmetric(horizontal: 10),
                              padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
                              opacity: 1,
                              blur: 0,
                              child: Text(state.message)
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
      buildWhen: (previous, current) {
        return current is GetPumpSettingsLoaded;
      },
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
                        menu,
                        isHiddenFlag: true,
                      );
                    },
                  );
                }),
                Divider(),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettingsList extends StatelessWidget {
  final int userId, subUserId, controllerId;
  final MenuItemEntity menu;
  final String deviceId;
  const _SettingsList({
    required this.menu,
    required this.deviceId,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: menu.template.sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = menu.template.sections[sectionIndex];
        if(section.settings.every((e) => e.hiddenFlag == "0")) return SizedBox();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                  section.sectionName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: Color(0xff303030),
                      fontWeight: FontWeight.w400
                  ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                margin: EdgeInsetsGeometry.symmetric(horizontal: 0),
                padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
                opacity: 1,
                blur: 0,
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (context) {
                    return ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          if(section.settings[index].hiddenFlag == "0") return SizedBox();
                          return _SettingRow(
                            menuItemEntity: menu,
                            sectionIndex: sectionIndex,
                            settingIndex: index,
                            deviceId: deviceId,
                            userId: userId,
                            subUserId: subUserId,
                            controllerId: controllerId,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          if (section.settings[index].widgetType != SettingWidgetType.multiText) {
                            if(section.settings[index].hiddenFlag == "0") return SizedBox();
                            return Divider();
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
  final int userId, subUserId, controllerId;
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
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PumpSettingsCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildInput(context)),
        const SizedBox(width: 8),
        IconButton(
          padding: EdgeInsets.zero,
          icon: context.watch<PumpSettingsCubit>().state is SettingsSendStartedState
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
              : Container(
            padding: EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/icons/send_icon.png',
              width: 25,
            ),
          ),
          onPressed: () {
            cubit.sendCurrentSetting(
                sectionIndex,
                settingIndex,
                deviceId,
                userId,
                subUserId,
                controllerId,
                menuItemEntity
            );
            context.read<PumpSettingsViewResponseCubit>().clear();
          },
        ),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    final setting = menuItemEntity.template.sections[sectionIndex].settings[settingIndex];
    final path = '${menuItemEntity.menu.menuSettingId}'
        '_${menuItemEntity.template.sections[sectionIndex].typeId}'
        '_${menuItemEntity.template.sections[sectionIndex].settings[settingIndex].serialNumber}';
    return switch (setting.widgetType) {
      SettingWidgetType.phone => _PhoneInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.multiTime => _MultiTimeInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.fullText => _TextInput(
        setting: setting,
        onChanged: _onChanged(context),
        label: setting.title,
        path: ([508].contains(menuItemEntity.menu.menuSettingId) && !([1,2].contains(menuItemEntity.template.sections[sectionIndex].typeId)))
            ? PumpSettingsImages.getCommunicationConfigIcons(path)
            : null,
      ),
      SettingWidgetType.multiText => _MultiTextInput(setting: setting, onChanged: _onChanged(context)),
      _ => SettingListTile(
        title: setting.title,
        leadingIcon: [509].contains(menuItemEntity.menu.menuSettingId) ? PumpSettingsImages.getStatusCheckIcons(path) : null,
        trailing: _buildTrailing(context),
        onTap: () => _handleTap(context),
      ),
    };
  }

  Widget _buildTrailing(BuildContext context) {
    final setting = menuItemEntity.template.sections[sectionIndex].settings[settingIndex];
    // print(setting.widgetType);
    return switch (setting.widgetType) {
      SettingWidgetType.nothing => Container(),
      SettingWidgetType.text => _TextInput(setting: setting, onChanged: _onChanged(context)),
      SettingWidgetType.toggle => SizedBox(
        width: 55,
        height: 25,
        child: CustomSwitch(
            value: setting.value == "ON",
            onChanged: (_) => _onChanged(context)(setting.value == "ON" ? "OF" : "ON")
        ),
      ),
      SettingWidgetType.time => LeafBox(
        margin: EdgeInsets.zero,
        height: 30,
        padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 3),
        child: Text(
            setting.value.isEmpty ? "00:00" : setting.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
        ),
      ),
      _ => Text(setting.value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
    };
  }

  void Function(String newValue) _onChanged(BuildContext context) {
    return (String newValue) {
      context.read<PumpSettingsCubit>().updateSettingValue(newValue, sectionIndex, settingIndex, menuItemEntity);
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        onChanged: (phone) => onChanged(phone.completeNumber),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final SettingsEntity setting;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? path;
  const _TextInput({required this.setting, required this.onChanged, this.label, this.path});

  @override
  Widget build(BuildContext context) {
    return LeafBox(
      height: 40,
      padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 3),
      child: TextFormField(
        initialValue: setting.value,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          isDense: true,
          prefixIcon: path != null ? Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(path!),
                ),
                VerticalDivider(endIndent: 5, indent: 5, thickness: 1,),
              ],
            ),
          ) : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
            maxWidth: 40,
            maxHeight: 40,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
        ),
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
                trailing: LeafBox(
                  height: 30,
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 3),
                  child: Center(
                    child: Text(
                      values[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
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
              )
      ),
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

    return Column(
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
                  child: Text(titles[i], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                )
          ],
        ),
        Row(
          spacing: 30,
          children: [
            for (int i = 0; i < values.length; i++)
              Flexible(
                child: LeafBox(
                  height: 30,
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 3),
                  child: TextFormField(
                    initialValue: values[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                    onChanged: (newValue) async {
                      final newValues = [...values]..[i] = newValue;
                      onChanged(newValues.join(';'));
                    },
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}

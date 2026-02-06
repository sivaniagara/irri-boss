import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/retry.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../bloc/pump_settings_event.dart';
import '../bloc/pump_settings_menu_bloc.dart';
import '../bloc/pump_settings_state.dart';
import '../cubit/pump_settings_cubit.dart';
import '../cubit/pump_settings_view_response_cubit.dart';
import '../widgets/setting_list_tile.dart';
import '../../../../core/di/injection.dart' as di;
import '../../utils/pump_settings_images.dart';
import '../../utils/pump_settings_page_routes.dart';

class PumpSettingsMenuPage extends StatelessWidget {
  final int userId, subUserId, controllerId;
  final String deviceId;

  const PumpSettingsMenuPage({
    super.key,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<PumpSettingsCubit>()),
        BlocProvider(
          create: (context) {
            final bloc = di.sl<PumpSettingsMenuBloc>()
              ..add(GetPumpSettingsMenuEvent(
                userId: userId,
                subUserId: subUserId,
                controllerId: controllerId,
              ));

            Future.microtask(() {
              context.read<PumpSettingsCubit>().loadSettings(
                userId: userId,
                subUserId: subUserId,
                controllerId: controllerId,
                menuId: 502,
              );
            });

            return bloc;
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pump Settings Menu"),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.hide_source),
                onPressed: () => _showHideMenuDialog(ctx),
              ),
            ),
          ],
        ),
        body: _MenuListView(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
          deviceId: deviceId,
        ),
      ),
    );
  }

  void _showHideMenuDialog(BuildContext context) {
    final cubit = context.read<PumpSettingsCubit>();

    GlassyAlertDialog.show(
      context: context,
      title: "Hide/Show Menu",
      content: BlocProvider.value(
        value: cubit,
        child: _HideShowSettingsDialog(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
          deviceId: deviceId,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

class _MenuListView extends StatelessWidget {
  final int userId, subUserId, controllerId;
  final String deviceId;

  const _MenuListView({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PumpSettingsMenuBloc, PumpSettingsState>(
      listenWhen: (_, state) => state is UpdateMenuStatusSuccess,
      listener: (context, _) {
        context.read<PumpSettingsMenuBloc>().add(GetPumpSettingsMenuEvent(
          userId: userId,
          subUserId: subUserId,
          controllerId: controllerId,
        ));
      },
      buildWhen: (_, state) =>
      state is GetPumpSettingsMenuInitial ||
          state is GetPumpSettingsMenuLoaded ||
          state is GetPumpSettingsMenuError,
      builder: (context, state) {
        if (state is GetPumpSettingsMenuInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GetPumpSettingsMenuError) {
          return Center(
            child: Retry(
              message: state.message,
              onPressed: () => context.read<PumpSettingsMenuBloc>().add(
                GetPumpSettingsMenuEvent(
                  userId: userId,
                  subUserId: subUserId,
                  controllerId: controllerId,
                ),
              ),
            ),
          );
        }

        if (state is! GetPumpSettingsMenuLoaded) {
          return const SizedBox.shrink();
        }

        return _buildGroupedMenu(context, state.settingMenuList);
      },
    );
  }

  Widget _buildGroupedMenu(BuildContext context, List<MenuItemEntity> items) {
    final grouped = <String, List<MenuItemEntity>>{};

    for (final item in items) {
      final group = item.menu.groupName;
      grouped.putIfAbsent(group, () => []).add(item);
    }

    final groupNames = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: groupNames.length,
      itemBuilder: (context, i) {
        final groupName = groupNames[i];
        final groupItems = grouped[groupName]!;

        if (groupName.isEmpty) {
          return _buildSpecialTwoPhaseTile(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                groupName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  color: const Color(0xff303030),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              opacity: 1,
              blur: 0,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Column(
                children: List.generate(
                  groupItems.length,
                      (index) => _MenuItemTile(
                    item: groupItems[index],
                    isLast: index == groupItems.length - 1,
                    userId: userId,
                    subUserId: subUserId,
                    controllerId: controllerId,
                    deviceId: deviceId,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSpecialTwoPhaseTile(BuildContext context) {
    return BlocSelector<PumpSettingsCubit, PumpSettingsState, MenuItemEntity?>(
      selector: (state) => state is GetPumpSettingsLoaded ? state.settings : null,
      builder: (context, item) {
        if (item == null) return const SizedBox.shrink();

        final setting = item.template.sections[0].settings[0];
        if (setting.hiddenFlag == "0") return const SizedBox.shrink();

        final isOn = setting.value == "ON";
        final isSending = context.watch<PumpSettingsCubit>().state is SettingsSendStartedState;

        return GlassCard(
          opacity: 1,
          blur: 0,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: SettingListTile(
                  title: setting.title,
                  trailing: SizedBox(
                    width: 55,
                    height: 25,
                    child: CustomSwitch(
                      value: isOn,
                      onChanged: (_) => _toggleTwoPhase(context, isOn, item),
                    ),
                  ),
                  onTap: () => _toggleTwoPhase(context, isOn, item),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
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
                onPressed: isSending
                    ? null
                    : () => _sendTwoPhaseSettings(context, item),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleTwoPhase(BuildContext context, bool isOn, MenuItemEntity item) {
    final newValue = isOn ? "OF" : "ON";
    context.read<PumpSettingsCubit>().updateSettingValue(newValue, 0, 0, item);
  }

  void _sendTwoPhaseSettings(BuildContext context, MenuItemEntity item) {
    final cubit = context.read<PumpSettingsCubit>();
    cubit.sendCurrentSetting(0, 0, deviceId, userId, subUserId, controllerId, item);
    context.read<PumpSettingsViewResponseCubit>().clear();
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemEntity item;
  final bool isLast;
  final int userId, subUserId, controllerId;
  final String deviceId;

  const _MenuItemTile({
    required this.item,
    required this.isLast,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              PumpSettingsImages.getMenuIcons(item.menu.menuSettingId),
              width: 20,
              height: 20,
            ),
            title: Text(
              item.menu.menuItem,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              final extra = {
                'userId': userId,
                'subUserId': subUserId,
                'controllerId': controllerId,
                'deviceId': deviceId,
              };

              final route = _getRouteForMenuId(item.menu.menuSettingId);

              context.push(
                route,
                extra: item.menu.menuSettingId == 514 || item.menu.menuSettingId == 515
                    ? extra
                    : {...extra, 'menuId': item.menu.menuSettingId, 'menuName': item.menu.menuItem},
              );
            },
          ),
          if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }

  String _getRouteForMenuId(int menuId) {
    switch (menuId) {
      case 514:
        return PumpSettingsPageRoutes.notificationsPage;
      case 515:
        return PumpSettingsPageRoutes.viewSettingsPage;
      default:
        return PumpSettingsPageRoutes.pumpSettingsPage;
    }
  }
}

class _HideShowSettingsDialog extends StatelessWidget {
  final int userId, subUserId, controllerId;
  final String deviceId;

  const _HideShowSettingsDialog({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PumpSettingsCubit, PumpSettingsState>(
      buildWhen: (_, state) => state is GetPumpSettingsLoaded,
      builder: (context, state) {
        if (state is! GetPumpSettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final setting = state.settings.template.sections[0].settings[0];

        return CheckboxListTile(
          title: Text(setting.title),
          value: setting.hiddenFlag == "1",
          onChanged: (bool? shouldHide) async {
            if (shouldHide == null) return;

            final cubit = context.read<PumpSettingsCubit>();

            cubit.updateSettingValue(
              shouldHide ? '1' : '0',
              0,
              0,
              state.settings,
              isHiddenFlag: true,
            );

            // Small delay to let state update
            await Future.delayed(const Duration(milliseconds: 60));

            final updated = cubit.state;
            if (updated is! GetPumpSettingsLoaded) return;

            await cubit.updateHiddenFlags(
              userId: userId,
              subUserId: subUserId,
              controllerId: controllerId,
              menuItemEntity: updated.settings,
              sentSms: "",
            );

            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }
}
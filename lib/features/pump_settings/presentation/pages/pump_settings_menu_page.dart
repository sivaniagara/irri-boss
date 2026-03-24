import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_card.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/retry.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../bloc/pump_settings_event.dart';
import '../bloc/pump_settings_menu_bloc.dart';
import '../bloc/pump_settings_state.dart';
import '../cubit/pump_settings_cubit.dart';
import '../cubit/pump_settings_view_response_cubit.dart';
import '../../../../core/di/injection.dart' as di;
import '../../utils/pump_settings_images.dart';
import '../../utils/pump_settings_page_routes.dart';

class PumpSettingsMenuPage extends StatelessWidget {
  final int userId, subUserId, controllerId, modelId;
  final String deviceId;

  const PumpSettingsMenuPage({
    super.key,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
    required this.modelId,
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
        appBar: CustomAppBar(
          title: "Pump Settings Menu",
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.settings_suggest_outlined, color: Colors.black),
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
          modelId: modelId,
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
        child: SizedBox(
          width: double.maxFinite,
          child: _HideShowSettingsDialog(
            userId: userId,
            subUserId: subUserId,
            controllerId: controllerId,
            deviceId: deviceId,
          ),
        ),
      ),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

class _MenuListView extends StatelessWidget {
  final int userId, subUserId, controllerId, modelId;
  final String deviceId;

  const _MenuListView({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
    required this.modelId,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: groupNames.length,
      itemBuilder: (context, i) {
        final groupName = groupNames[i];
        final groupItems = grouped[groupName]!;

        if (groupName.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildSpecialTwoPhaseTile(context),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                groupName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            CustomCard(
              horizontalPadding: 0,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: groupItems.length,
                separatorBuilder: (context, index) => const Divider(thickness: 0.6, height: 1, indent: 45,),
                itemBuilder: (context, itemIndex) {
                  return _MenuItemTile(
                    item: groupItems[itemIndex],
                    userId: userId,
                    subUserId: subUserId,
                    controllerId: controllerId,
                    deviceId: deviceId,
                    modelId: modelId,
                  );
                },
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
        final isSending = context.watch<PumpSettingsCubit>().state is SettingSendingState;

        return CustomCard(
          horizontalPadding: 16,
          child: Row(
            children: [
              Expanded(
                child: _navigationRow(
                  context,
                  title: setting.title,
                  trailing: SizedBox(
                    width: 50,
                    height: 25,
                    child: FittedBox(
                      child: CustomSwitch(
                        value: isOn,
                        onChanged: (_) => _toggleTwoPhase(context, isOn, item),
                      ),
                    ),
                  ),
                  onTap: () => _toggleTwoPhase(context, isOn, item),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Image.asset(
                        'assets/images/icons/send_icon.png',
                        width: 22,
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

  static Widget _navigationRow(BuildContext context, {required String title, Widget? trailing, VoidCallback? onTap, String? image}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            if (image != null) ...[
              Image.asset(
                image,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemEntity item;
  final int userId, subUserId, controllerId, modelId;
  final String deviceId;

  const _MenuItemTile({
    required this.item,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    return _MenuListView._navigationRow(
      context,
      image: PumpSettingsImages.getMenuIcons(item.menu.menuSettingId),
      title: item.menu.menuItem,
      onTap: () {
        final extra = {
          'userId': userId,
          'subUserId': subUserId,
          'controllerId': controllerId,
          'deviceId': deviceId,
          'modelId': modelId,
        };

        final route = _getRouteForMenuId(item.menu.menuSettingId);

        context.push(
          route,
          extra: item.menu.menuSettingId == 514 || item.menu.menuSettingId == 515
              ? extra
              : {...extra, 'menuId': item.menu.menuSettingId, 'menuName': item.menu.menuItem},
        );
      },
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
          title: Text(setting.title, style: const TextStyle(fontSize: 14),),
          value: setting.hiddenFlag == "1",
          dense: true,
          contentPadding: EdgeInsets.zero,
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

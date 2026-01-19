import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import '../../../../core/widgets/glass_effect.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../presentation/bloc/pump_settings_event.dart';
import '../../presentation/bloc/pump_settings_state.dart';

import '../../../../core/di/injection.dart' as di;
import '../../../../core/widgets/retry.dart';
import '../../utils/pump_settings_images.dart';
import '../bloc/pump_settings_menu_bloc.dart';

class PumpSettingsMenuPage extends StatelessWidget {
  final int userId, subUserId, controllerId;
  final String deviceId;
  const PumpSettingsMenuPage({
    super.key,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId
  });

  @override
  Widget build(BuildContext dialogContext) {
    return BlocProvider(
      create: (context) => di.sl<PumpSettingsMenuBloc>()
        ..add(GetPumpSettingsMenuEvent(
            userId: userId, subUserId: subUserId, controllerId: controllerId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Pump Settings Menu"),
          actions: [
            Builder(
              builder: (appBarContext) => IconButton(
                onPressed: () async {
                  final bloc = appBarContext.read<PumpSettingsMenuBloc>();

                  GlassyAlertDialog.show(
                    context: appBarContext,
                    title: "Hide/Show Menu",
                    content: BlocProvider.value(
                      value: bloc,
                      child: _HideShowSettingsDialog(userId: userId, controllerId: controllerId, subUserId: subUserId,),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(appBarContext).pop(),
                        child: const Text("Cancel"),
                      ),
                    ],
                  );
                },
                icon: const Icon(Icons.hide_source),
              ),
            ),
          ],
        ),
        body: _buildBody(dialogContext),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<PumpSettingsMenuBloc, PumpSettingsState>(
      listenWhen: (previous, current) => current is UpdateMenuStatusSuccess,
      listener: (context, state) {
        if (state is UpdateMenuStatusSuccess) {
          context.read<PumpSettingsMenuBloc>().add(GetPumpSettingsMenuEvent(
            userId: userId,
            subUserId: subUserId,
            controllerId: controllerId,
          ));
        }
      },
      buildWhen: (previous, current) {
        return current is GetPumpSettingsMenuInitial ||
            current is GetPumpSettingsMenuLoaded ||
            current is GetPumpSettingsMenuError;
      },
        builder: (context, state) {
          if (state is GetPumpSettingsMenuInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetPumpSettingsMenuLoaded) {
            final List<MenuItemEntity> additionalSettings = [];

            final List<MenuItemEntity> visibleSettings = [
              ...state.settingMenuList,
              ...additionalSettings,
            ].where((item) => item.menu.hiddenFlag != 0).toList();

            return _buildSettingMenuList(context, visibleSettings);
          } else if (state is GetPumpSettingsMenuError) {
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

          return const SizedBox.shrink();
        },
    );
  }

  Widget _buildSettingMenuList(BuildContext context, List<MenuItemEntity> settingMenuList) {
    final grouped = <String, List<MenuItemEntity>>{};

    for (final item in settingMenuList) {
      if (item.menu.hiddenFlag == 0) continue;

      final group = item.menu.groupName;
      grouped.putIfAbsent(group, () => []).add(item);
    }

    final groupNames = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: groupNames.length,
      itemBuilder: (context, groupIndex) {
        final groupName = groupNames[groupIndex];
        final itemsInGroup = grouped[groupName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(groupName.isNotEmpty)
              ...[
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
              ],

            const SizedBox(height: 8),

            GlassCard(
              opacity: 1,
              blur: 0,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Column(
                children: List.generate(itemsInGroup.length, (i) {
                  final item = itemsInGroup[i];

                  return Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            item.menu.menuItem,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: groupName.isNotEmpty ? Image.asset(PumpSettingsImages.getMenuIcons(item.menu.menuSettingId,), width: 20, height: 20,) : null,
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            final commonExtra = {
                              'userId': userId,
                              'controllerId': controllerId,
                              'subUserId': subUserId,
                              'deviceId': deviceId,
                            };

                            switch (item.menu.menuSettingId) {
                              case 514:
                                context.push(
                                  PumpSettingsPageRoutes.notificationsPage,
                                  extra: commonExtra,
                                );
                                break;

                              case 515:
                                context.push(
                                  PumpSettingsPageRoutes.viewSettingsPage,
                                  extra: commonExtra,
                                );
                                break;

                              default:
                                context.push(
                                  PumpSettingsPageRoutes.pumpSettingsPage,
                                  extra: {
                                    ...commonExtra,
                                    'menuId': item.menu.menuSettingId,
                                    'menuName': item.menu.menuItem,
                                  },
                                );
                            }
                          },
                        ),
                        if (i < itemsInGroup.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _HideShowSettingsDialog extends StatelessWidget {
  final int userId, controllerId, subUserId;

  const _HideShowSettingsDialog({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PumpSettingsMenuBloc, PumpSettingsState>(
      listenWhen: (previous, current) {
        return current is UpdateMenuStatusSuccess || current is UpdateMenuStatusFailure;
      },
      listener: (context, state) {
        if (state is UpdateMenuStatusSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is UpdateMenuStatusFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${state.message}")),
          );
        }
      },
      child: BlocBuilder<PumpSettingsMenuBloc, PumpSettingsState>(
        buildWhen: (previous, current) => current is GetPumpSettingsMenuLoaded,
        builder: (context, state) {
          if (state is! GetPumpSettingsMenuLoaded || state.settingMenuList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = state.settingMenuList[0].menu;
          final isVisible = item.hiddenFlag == 1;

          return CheckboxListTile(
            title: Text(item.menuItem),
            value: isVisible,
            onChanged: (bool? newValue) {
              if (newValue == null) return;

              final updatedItem = item.copyWith(newValue ? 1 : 0);

              context.read<PumpSettingsMenuBloc>().add(
                UpdateHiddenFlagsEvent(
                  userId: userId,
                  subUserId: subUserId,
                  controllerId: controllerId,
                  settingsMenuEntity: updatedItem,
                ),
              );

              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}

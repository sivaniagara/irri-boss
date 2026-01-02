import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/alert_dialog.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import '../../../../core/widgets/glass_effect.dart';
import '../../../../core/widgets/glassy_wrapper.dart';
import '../../domain/entities/settings_menu_entity.dart';
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
      child: GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
            final List<SettingsMenuEntity> additionalSettings = [
              SettingsMenuEntity(
                  menuSettingId: 513,
                  referenceId: 600,
                  menuItem: "Notifications",
                  templateName: "Notifications",
                  hiddenFlag: 1),
              SettingsMenuEntity(
                  menuSettingId: 514,
                  referenceId: 600,
                  menuItem: "Pump Setting View",
                  templateName: "Pump Setting View",
                  hiddenFlag: 1),
            ];

            final List<SettingsMenuEntity> visibleSettings = [
              ...state.settingMenuList,
              ...additionalSettings,
            ].where((item) => item.hiddenFlag != 0).toList();

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

  Widget _buildSettingMenuList(BuildContext context, List<SettingsMenuEntity> settingMenuList) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: settingMenuList.length,
      itemBuilder: (BuildContext context, int index) {
        final item = settingMenuList[index];
        if(item.hiddenFlag == 0) return SizedBox();
        return GlassCard(
          opacity: 1,
          blur: 0,
          padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 10),
          child: InkWell(
            onTap: () {
              // print(item.menuSettingId);
              final commonExtra = {
                'userId': userId,
                'controllerId': controllerId,
                'subUserId': subUserId,
                'deviceId': deviceId
              };

              switch (item.menuSettingId) {
                case 513:
                  context.push(
                    PumpSettingsPageRoutes.notificationsPage,
                    extra: commonExtra,
                  );
                  return;

                case 514:
                  context.push(
                    PumpSettingsPageRoutes.viewSettingsPage,
                    extra: commonExtra,
                  );
                  return;

                default:
                  context.push(
                    PumpSettingsPageRoutes.pumpSettingsPage,
                    extra: {
                      ...commonExtra,
                      'menuId': item.menuSettingId,
                      'menuName': item.templateName,
                    },
                  );
              }
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
                  child: Image.asset(PumpSettingsImages.getByIndex(index)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.menuItem,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Icon(Icons.navigate_next, color: Theme.of(context).primaryColor,)
                  ],
                ),
              ],
            ),
          ),
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
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

          final item = state.settingMenuList[0];
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

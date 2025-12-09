import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import '../../../../core/widgets/glass_effect.dart';
import '../../../../core/widgets/glassy_wrapper.dart';
import '../../domain/entities/settings_menu_entity.dart';
import '../../presentation/bloc/pump_settings_event.dart';
import '../../presentation/bloc/pump_settings_state.dart';

import '../../../../core/di/injection.dart' as di;
import '../../../../core/widgets/retry.dart';
import '../bloc/pump_settings_menu_bloc.dart';

class PumpSettingsMenuPage extends StatelessWidget {
  final int userId, subUserId, controllerId;
  const PumpSettingsMenuPage({super.key, required this.userId, required this.subUserId, required this.controllerId});

  @override
  Widget build(BuildContext dialogContext) {
    return BlocProvider(
        create: (context) => di.sl<PumpSettingsMenuBloc>()
          ..add(GetPumpSettingsMenuEvent(userId: userId, subUserId: subUserId, controllerId: controllerId)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Pump Settings Menu"),
          actions: [
            IconButton(
                onPressed: null,
                icon: Icon(Icons.hide_source, color: Colors.white,)
            )
          ],
        ),
        body: GlassyWrapper(
            child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: _buildBody(dialogContext)
            )
        ),
      ),
    );
  }

  Widget _buildBody (BuildContext context) {
    return BlocBuilder<PumpSettingsMenuBloc, PumpSettingsState>(
        builder: (context, state) {
          if(state is GetPumpSettingsMenuInitial) {
            return Center(
              child: CircularProgressIndicator()
            );
          }
          else if(state is GetPumpSettingsMenuLoaded) {
            return _buildSettingMenuList(context, state.settingMenuList);
          } else if(state is GetPumpSettingsMenuError) {
            return Center(
              child: Retry(
                message: state.message,
                onPressed: () => context.read<PumpSettingsMenuBloc>().add(
                    GetPumpSettingsMenuEvent(userId: userId, subUserId: subUserId, controllerId: controllerId)
                ),
              ),
            );
          }
          return SizedBox();
        }
    );
  }

  Widget _buildSettingMenuList(BuildContext context, List<SettingsMenuEntity> settingMenuList) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: settingMenuList.length,
      itemBuilder: (BuildContext context, int index) {
        final item = settingMenuList[index];
        return GlassCard(
          child: InkWell(
            onTap: () {
              context.push(
                  PumpSettingsPageRoutes.pumpSettingsPage,
                  extra: {
                    'userId' : userId,
                    'controllerId': controllerId,
                    'subUserId' : subUserId,
                    'menuId': item.menuSettingId,
                    'menuName': item.templateName
                  }
              );
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Icon(Icons.settings, size: 25.0,),
                Text(
                  item.menuItem,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
    );
  }
}

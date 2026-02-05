import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_images.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/utils/common_id_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/serial_set/utils/serial_set_routes.dart';
import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../../irrigation_settings/utils/irrigation_settings_routes.dart';
import '../../../mapping_and_unmapping_nodes/utils/mapping_and_unmapping_nodes_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
            context: context,
            title: 'Pump Settings',
            iconPath: AppImages.pumpSettingIcon,
            onTap: () {
              final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
              context.push(
                  PumpSettingsPageRoutes.pumpSettingMenuList,
                extra: {
                    'userId': int.parse(controllerContext.userId).toString(),
                    'controllerId': int.parse(controllerContext.controllerId).toString(),
                    'userType': int.parse(controllerContext.userType).toString(),
                    'subUserId': int.parse(controllerContext.subUserId).toString(),
                    'deviceId': controllerContext.deviceId,
                }
              );
            }
        ),
        _buildSettingsItem(
            context: context,
            title: 'Irrigation Settings',
            iconPath: AppImages.irrigationSettingIcon,
            onTap: () {
              context.push(IrrigationSettingsRoutes.irrigationSettings);
            }
        ),
        _buildSettingsItem(
            context: context,
            title: 'Node Settings',
            iconPath: AppImages.irrigationSettingIcon,
            onTap: () {
              context.push(MappingAndUnmappingNodesRoutes.nodeSetting);
            }
        ),
        _buildSettingsItem(
            context: context,
            title: 'Common Id Settings',
            iconPath: AppImages.irrigationSettingIcon,
            onTap: () {
              context.push(CommonIdSettingsRoutes.commonIdSettings);
            }
        ),
        _buildSettingsItem(
            context: context,
            title: 'Serial Set',
            iconPath: AppImages.setserialIcon,
            onTap: () {
              final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
              context.push(
                  SerialSetRoutes.serialSetMenu,
                  extra: {
                    'userId': controllerContext.userId,
                    'controllerId': controllerContext.controllerId,
                    'deviceId': controllerContext.deviceId,
                    'subUserId': controllerContext.subUserId,
                  }
              );
            }
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required String title,
    required String iconPath,
    required void Function()? onTap,
  }){
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Image.asset(iconPath, width: 20,),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20,),
      ),
    );
  }

}

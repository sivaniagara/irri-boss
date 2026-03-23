import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_constants.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_images.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/route_constants.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/utils/common_id_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_details/domain/usecase/controller_details_params.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/enums/irrigation_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/serial_set/utils/serial_set_routes.dart';
import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../../irrigation_settings/utils/irrigation_settings_routes.dart';
import '../../../mapping_and_unmapping_nodes/utils/mapping_and_unmapping_nodes_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControllerContextCubit, ControllerContextState>(
      builder: (context, state) {
        if (state is! ControllerContextLoaded) {
          return const Center(child: Text("Please select a controller first."));
        }
        final controllerContext = state;
        final int modelId = controllerContext.modelId;

        // Condition check based on modelId
        final bool isDoublePump = AppConstants.isDoublePumpLive(modelId);
        final bool isSinglePump = AppConstants.isPumpLive(modelId);
        final bool isAnyPump = isDoublePump || isSinglePump;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Always show Controller Details for all models including Single and Double Pump
              _buildSettingsItem(
                  context: context,
                  title: 'Controller Details',
                  iconPath: AppImages.ControllerDetailsIcon,
                  onTap: () {
                    context.push(
                      RouteConstants.ctrlDetailsPage,
                      extra: GetControllerDetailsParams(
                        userId: int.parse(controllerContext.userId),
                        controllerId: int.parse(controllerContext.controllerId),
                        deviceId: controllerContext.deviceId,
                      ),
                    );
                  }
              ),

              // Always Show Pump Settings (Required for Drip and Standalone Pumps)
              _buildSettingsItem(
                  context: context,
                  title: 'Pump Settings',
                  iconPath: AppImages.pumpSettingIcon,
                  onTap: () {
                    context.push(
                        PumpSettingsPageRoutes.pumpSettingMenuList,
                      extra: {
                          'userId': controllerContext.userId,
                          'controllerId': controllerContext.controllerId,
                          'userType': controllerContext.userType,
                          'subUserId': controllerContext.subUserId,
                          'deviceId': controllerContext.deviceId,
                          'modelId': controllerContext.modelId,
                      }
                    );
                  }
              ),

              // Show Sump Settings ONLY for Double Pump
              if (isDoublePump)
                _buildSettingsItem(
                    context: context,
                    title: 'Sump Settings',
                    iconPath: 'assets/images/common/sump_setting.png',
                    onTap: () {
                      final String settingName = "Sump Settings";
                      final int settingNo = IrrigationSettingsEnum.sump.settingId; // 523
                      
                      context.push(
                        "/irrigationSettings/templateSetting/$settingName/$settingNo",
                      );
                    }
                ),

              // Hide these items for Single and Double Pump models
              if (!isAnyPump) ...[
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
            ],
          ),
        );
      }
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_images.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/leaf_box.dart';

import '../../../irrigation_settings/utils/irrigation_settings_routes.dart';

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
            onTap: () {  }
        ),
        _buildSettingsItem(
            context: context,
            title: 'Irrigation Settings',
            iconPath: AppImages.irrigationSettingIcon,
            onTap: () {
              context.push(IrrigationSettingsRoutes.irrigationSettings);
            }
        )
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
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline)
      ),
      child: ListTile(
        onTap: onTap,
        leading: Image.asset(iconPath, width: 30,),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 20,),
      ),
    );
  }
}

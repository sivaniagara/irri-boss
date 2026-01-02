import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/fault_msg/utils/faultmsg_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/reportMenu/utils/report_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/standalone_reports/utils/standalone_report_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/utils/standalone_routes.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../sendrev_msg/utils/senrev_routes.dart';
import '../../utils/dashboard_routes.dart';

class ActionsSection extends StatelessWidget {
  final int model;
  final Map<String, dynamic> data;
  const ActionsSection({super.key, required this.model, required this.data});

  @override
  Widget build(BuildContext dialogContext) {
    return ([1, 5].contains(model)) ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: MenuButton(
              icon: Icons.settings,
              title: "Pump\nSettings",
              onTap: () {
                dialogContext.push(PumpSettingsPageRoutes.pumpSettingMenuList, extra: data);
              },
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.insert_chart,
              title: "Report",
              onTap: () {
                dialogContext.push(ReportPageRoutes.reportMenu, extra: data);
              },
             ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.touch_app,
              title: "Stand\nalone",
              onTap: () {
                dialogContext.push(StandaloneRoutes.standalone, extra: data);

              },
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.email,
              title: "Message",
              onTap: () {
                dialogContext.push(SendRevPageRoutes.sendRevMsgPage,extra: data);
              },
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.error_sharp,
              title: "Fault\nMessage",
              onTap: () {
                dialogContext.push(FaultMsgPageRoutes.FaultMsgMsgPage,extra: data);
              },
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.settings,
              title: "Irrigation",
              onTap: () {
                dialogContext.push('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}');
              },
            ),
          ),
        ],
      ),
    ) : Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Expanded(
            child: MenuButton(
              icon: Icons.settings,
              title: "Pump\nSettings",
              onTap: () {
                dialogContext.push(PumpSettingsPageRoutes.pumpSettingMenuList, extra: data);
              },
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.insert_chart,
              title: "Power\nGraph",
              onTap: () {
                dialogContext.push(ReportPageRoutes.reportMenu, extra: data);
              },
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.email,
              title: "Message",
              onTap: () {
                dialogContext.push(SendRevPageRoutes.sendRevMsgPage,extra: data);
              },
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.error_sharp,
              title: "Fault\nMessage",
              onTap: () {
                dialogContext.push(FaultMsgPageRoutes.FaultMsgMsgPage,extra: data);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isEnabled;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.title,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        height: 120,
        margin: const EdgeInsets.all(1.5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
            colors: [Colors.white70, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : null,
          color: isEnabled ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Icon with circular background (Top aligned)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEnabled
                      ? AppThemes.primaryColor
                      : Colors.grey.withValues(alpha: 0.2),
                ),
                child: Icon(
                  icon,
                  color:
                  isEnabled ? Colors.white : Colors.grey,
                  size: 26,
                ),
              ),
            ),

            const Spacer(),

            // 🔹 Title centered
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                isEnabled ? AppThemes.primaryColor : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}



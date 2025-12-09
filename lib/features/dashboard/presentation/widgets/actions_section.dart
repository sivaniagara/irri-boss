import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';

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
              onTap: () {},
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.touch_app,
              title: "Stand\nalone",
              onTap: () {},
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.email,
              title: "Message",
              onTap: () {},
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.settings,
              title: "Irrigation\nSettings",
              onTap: () {},
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
              onTap: () {},
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.email,
              title: "Message",
              onTap: () {},
            ),
          ),
          Expanded(
            child: MenuButton(
              icon: Icons.error_sharp,
              title: "Fault\nMessage",
              onTap: () {},
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
  Widget build(BuildContext dialogContext) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: GlassCard(
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.all(1.5),
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          // decoration: BoxDecoration(
          //   gradient: isEnabled
          //       ? const LinearGradient(
          //     colors: [Color(0xFF1B2A38), Color(0xFF3D648A)],
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //   )
          //       : null,
          //   color: isEnabled ? null : Colors.white,
          //   borderRadius: BorderRadius.circular(20),
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.grey,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



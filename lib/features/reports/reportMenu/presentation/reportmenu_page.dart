import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/utils/motor_cyclic_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/utils/voltage_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zone_duration_reports/utils/zone_duration_routes.dart';

import '../../../../core/theme/app_gradients.dart';
 import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';

import '../../../../core/theme/app_styles.dart';
import '../../power_reports/utils/Power_routes.dart';

class ReportMenuPage extends StatelessWidget {
   final Map<String, dynamic> params;

  const ReportMenuPage({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.commonGradient,) ,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _header(context),
              const SizedBox(height: 16),
              Expanded(child: _gridMenu(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
           Text(
            'REPORTS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _gridMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _reportCard(
            title: 'Voltage',
            icon: Icons.flash_on,
            onTap: () {
              context.push(VoltGraphPageRoutes.voltGraphPage,extra: params);
            },
          ),
          _reportCard(
            title: 'Power Graph',
            icon: Icons.power,
            onTap: () {
              context.push(PowerGraphPageRoutes.PowerGraphPage,extra: params);
            },
          ),
          _reportCard(
            title: 'Motor Cyclic',
            icon: Icons.touch_app,
            onTap: () {
              context.push(MotorCyclicPageRoutes.MotorCyclicpage,extra: params);
            },
          ),
          _reportCard(
            title: 'Zone Duration',
            icon: Icons.timer,
            onTap: () {
              context.push(ZoneDurationPageRoutes.ZoneDurationpage,extra: params);
            },
          ),
          _reportCard(
            title: 'Standalone',
            icon: Icons.touch_app,
            onTap: () {},
          ),
          _reportCard(
            title: 'Today Zone',
            icon: Icons.watch_later,
            onTap: () {},
          ),
          _reportCard(
            title: 'Zone Duration',
            icon: Icons.timer,
            onTap: () {},
          ),
          _reportCard(
            title: 'Zone Duration',
            icon: Icons.timer,
            onTap: () {},
          ),
          _reportCard(
            title: 'Zone Duration',
            icon: Icons.timer,
            onTap: () {},
          ),
          _reportCard(
            title: 'Fertilizer Live',
            icon: Icons.agriculture,
            onTap: () {},
          ),
          _reportCard(
            title: 'Fertilizer Live',
            icon: Icons.agriculture,
            onTap: () {},
          ),
          _reportCard(
            title: 'Fertilizer Live',
            icon: Icons.agriculture,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: AppStyles.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppThemes.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black
              ),
            ),
          ],
        ),
      ),
    );
  }
}

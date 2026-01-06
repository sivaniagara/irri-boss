import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/utils/motor_cyclic_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/utils/voltage_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/fertilizer_reports/utils/fertilizer_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/flow_graph_reports/utils/flow_graph_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/green_house_reports/utils/green_house_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/tdy_valve_status_reports/utils/tdy_valve_status_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zone_duration_reports/utils/zone_duration_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/utils/zone_cyclic_routes.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import '../../../../core/theme/app_styles.dart';
 import '../../../../core/widgets/glassy_wrapper.dart';
import '../../moisture_reports/utils/moisture_routes.dart';
import '../../power_reports/utils/Power_routes.dart';
import '../../standalone_reports/utils/standalone_report_routes.dart';

class ReportMenuPage extends StatelessWidget {
   final Map<String, dynamic> params;

  const ReportMenuPage({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        body: SafeArea(
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
            icon: Icons.event_repeat_sharp,
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
            onTap: () {
              context.push(StandaloneReportPageRoutes.Standalonepage,extra: params);
            },
          ),
          _reportCard(
            title: 'Today Zone',
            icon: Icons.today,
            onTap: () {
               context.push(TdyValveStatusPageRoutes.TdyValveStatuspage,extra: params);
            },
          ),
          _reportCard(
            title: 'Zone Cyclic',
            icon: Icons.query_builder_sharp,
            onTap: () {
              context.push(ZoneCyclicPageRoutes.ZoneCyclicpage,extra: params);
            },
          ),
          _reportCard(
            title: 'Flow Graph',
            icon: Icons.water_outlined,
            onTap: () {
              context.push(FlowGraphPageRoutes.FlowGraphpage,extra: params);
            },
          ),
          _reportCard(
            title: 'Fertilizer',
            icon: Icons.timer,
            onTap: () {
              context.push(FertilizerPageRoutes.Fertilizerpage,extra: params);
            },
          ),
          _reportCard(
            title: 'Moisture',
            icon: Icons.lens_blur,
            onTap: () {
              context.push(MoistureReportPageRoutes.Moisturepage,extra: params);
            },
          ),
          _reportCard(
            title: 'Fertilizer Live',
            icon: Icons.agriculture,
            onTap: () {},
          ),
          _reportCard(
            title: 'Green House',
            icon: Icons.house,
            onTap: () {
               context.push(GreenHouseReportPageRoutes.greenHouseReportPage,extra: params);
            },
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

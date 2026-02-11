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
 import '../../../../core/widgets/glassy_wrapper.dart';
import '../../fert_live/fert_live_page.dart';
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
              Expanded(child: _menuList(context)),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

   Widget _sectionTitle(String title) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8, top: 16),
       child: Text(
         title,
         style: const TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w600,
           color: Colors.black87,
         ),
       ),
     );
   }

   Widget _card(List<Widget> children) {
     return Container(
       margin: const EdgeInsets.only(bottom: 8),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 8,
           ),
         ],
       ),
       child: Column(children: children),
     );
   }

   Widget _menuList(BuildContext context) {
     return ListView(
       padding: const EdgeInsets.all(16),
       children: [

         _sectionTitle('Power & Motor Performance Reports'),
         _card([
           _menuItem(
             icon:'assets/images/report_menu/voltage_report.png',
             title: 'Voltage Report',
             onTap: () => context.push(
               VoltGraphPageRoutes.voltGraphPage,
               extra: params,
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(left: 20, right: 20),
             child: Container(height: 0.5,color: Colors.grey,),
           ),
           _menuItem(
             icon: 'assets/images/report_menu/power_graph.png',
             title: 'Power Graph',
             onTap: () => context.push(
               PowerGraphPageRoutes.PowerGraphPage,
               extra: params,
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(left: 20, right: 20),
             child: Container(height: 0.5,color: Colors.grey,),
           ),
           _menuItem(
             icon: 'assets/images/report_menu/motor_cyclic.png',
             title: 'Motor Cyclic',
             onTap: () => context.push(
               MotorCyclicPageRoutes.MotorCyclicpage,
               extra: params,
             ),
           ),
         ]),

         _sectionTitle('Zone Performance Reports'),
         _card([
           _menuItem(
             icon: 'assets/images/report_menu/zone_duration.png',
             title: 'Zone Duration',
             onTap: () => context.push(
               ZoneDurationPageRoutes.ZoneDurationpage,
               extra: params,
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(left: 20, right: 20),
             child: Container(height: 0.5,color: Colors.grey,),
           ),
           _menuItem(
             icon: 'assets/images/report_menu/today_zone.png',
             title: 'Today Zone',
             onTap: () => context.push(
               TdyValveStatusPageRoutes.TdyValveStatuspage,
               extra: params,
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(left: 20, right: 20),
             child: Container(height: 0.5,color: Colors.grey,),
           ),
           _menuItem(
             icon: 'assets/images/report_menu/zone_cyclic.png',
             title: 'Zone Cyclic',
             onTap: () => context.push(
               ZoneCyclicPageRoutes.ZoneCyclicpage,
               extra: params,
             ),
           ),
         ]),

         _sectionTitle('Water Usage Reports'),
         _card([
           _menuItem(
             icon: 'assets/images/report_menu/flow_graph.png',
             title: 'Flow Graph',
             onTap: () => context.push(
               FlowGraphPageRoutes.FlowGraphpage,
               extra: params,
             ),
           ),
         ]),

         _sectionTitle('Fertilizer & Soil Reports'),
         _card([
           _menuItem(
             icon:'assets/images/report_menu/fertilizer_report.png',
             title: 'Fertilizer',
             onTap: () => context.push(
               FertilizerPageRoutes.Fertilizerpage,
               extra: params,
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(left: 20, right: 20),
             child: Container(height: 0.5,color: Colors.grey,),
           ),
           _menuItem(
             icon: 'assets/images/report_menu/fertilizer_live.png',
             title: 'Fertilizer Live',
             onTap: () {
               // Using rootNavigator: true to bypass the parent Dashboard shell app bar
               Navigator.of(context, rootNavigator: true).push(
                 MaterialPageRoute(
                   builder: (_) => FertilizerLivePage(
                     deviceId: params['deviceId'].toString(), 
                   ),
                 ),
               );
             },
           ),
           Padding(
             padding: const EdgeInsets.only(left: 20, right: 20),
             child: Container(height: 0.5,color: Colors.grey,),
           ),
           _menuItem(
             icon: 'assets/images/report_menu/moisture_report.png',
             title: 'Moisture',
             onTap: () => context.push(
               MoistureReportPageRoutes.Moisturepage,
               extra: params,
             ),
           ),
         ]),

         _sectionTitle('System & Greenhouse Reports'),
         _card([
           _menuItem(
             icon: 'assets/images/report_menu/stand_alone.png',
             title: 'Standalone',
             onTap: () => context.push(
               StandaloneReportPageRoutes.Standalonepage,
               extra: params,
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(left: 20, right: 20),
             child: Container(height: 0.5,color: Colors.grey,),
           ),
           _menuItem(
             icon: 'assets/images/report_menu/green_house.png',
             title: 'Green House',
             onTap: () => context.push(
               GreenHouseReportPageRoutes.greenHouseReportPage,
               extra: params,
             ),
           ),
         ]),
       ],
     );
   }

   Widget _menuItem({
     required String icon,
     required String title,
     required VoidCallback onTap,
   }) {
     return ListTile(
       leading: Image.asset(
         icon,
         width: 20,
         height: 20,
         color: AppThemes.primaryColor,
       ),
       title: Text(
         title,
         style: const TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w500,
         ),
       ),
       trailing: const Icon(Icons.chevron_right),
       onTap: onTap,
     );
   }

}

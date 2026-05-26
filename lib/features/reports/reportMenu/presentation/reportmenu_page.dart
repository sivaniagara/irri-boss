import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../bloc/report_menu_bloc.dart';
import '../bloc/report_menu_event.dart';
import '../bloc/report_menu_state.dart';

class ReportMenuPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const ReportMenuPage({
    super.key,
    required this.params,
  });

  @override
  State<ReportMenuPage> createState() => _ReportMenuPageState();
}

class _ReportMenuPageState extends State<ReportMenuPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportMenuBloc>().add(FetchReportMenuData(
          userId: widget.params['userId'].toString(),
          controllerId: widget.params['controllerId'].toString(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ReportMenuBloc, ReportMenuState>(
            builder: (context, state) {
              if (state is ReportMenuLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ReportMenuError) {
                return Center(child: Text(state.message));
              } else if (state is ReportMenuLoaded) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(child: _menuList(context, state)),
                    const SizedBox(height: 70),
                  ],
                );
              }
              return const SizedBox();
            },
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
    if (children.isEmpty) return const SizedBox();
    
    // Filter out potential dividers if they end up being at the edges or consecutive
    List<Widget> filteredChildren = [];
    for (int i = 0; i < children.length; i++) {
      if (children[i] is _Divider) {
        if (filteredChildren.isNotEmpty && i < children.length - 1 && children[i+1] is! _Divider) {
          filteredChildren.add(children[i]);
        }
      } else {
        filteredChildren.add(children[i]);
      }
    }

    if (filteredChildren.isEmpty) return const SizedBox();

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
      child: Column(children: filteredChildren),
    );
  }

  Widget _menuList(BuildContext context, ReportMenuLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Power & Motor Performance Reports'),
        _card([
          _menuItem(
            icon: 'assets/images/report_menu/voltage_report.png',
            title: 'Voltage Report',
            onTap: () => context.push(
              VoltGraphPageRoutes.voltGraphPage,
              extra: widget.params,
            ),
          ),
          const _Divider(),
          _menuItem(
            icon: 'assets/images/report_menu/power_graph.png',
            title: 'Power Graph',
            onTap: () => context.push(
              PowerGraphPageRoutes.PowerGraphPage,
              extra: widget.params,
            ),
          ),
          const _Divider(),
          _menuItem(
            icon: 'assets/images/report_menu/motor_cyclic.png',
            title: 'Motor Cyclic',
            onTap: () => context.push(
              MotorCyclicPageRoutes.MotorCyclicpage,
              extra: widget.params,
            ),
          ),
        ]),
        _sectionTitle('Block Performance Reports'),
        _card([
          _menuItem(
            icon: 'assets/images/report_menu/zone_duration.png',
            title: 'Block Duration',
            onTap: () => context.push(
              ZoneDurationPageRoutes.ZoneDurationpage,
              extra: widget.params,
            ),
          ),
          const _Divider(),
          _menuItem(
            icon: 'assets/images/report_menu/today_zone.png',
            title: 'Today Block',
            onTap: () => context.push(
              TdyValveStatusPageRoutes.TdyValveStatuspage,
              extra: widget.params,
            ),
          ),
          const _Divider(),
          _menuItem(
            icon: 'assets/images/report_menu/zone_cyclic.png',
            title: 'Block Cyclic',
            onTap: () => context.push(
              ZoneCyclicPageRoutes.ZoneCyclicpage,
              extra: widget.params,
            ),
          ),
        ]),
        if (state.hasFlowMeter) ...[
          _sectionTitle('Water Usage Reports'),
          _card([
            _menuItem(
              icon: 'assets/images/report_menu/flow_graph.png',
              title: 'Flow Graph',
              onTap: () => context.push(
                FlowGraphPageRoutes.FlowGraphpage,
                extra: widget.params,
              ),
            ),
          ]),
        ],
        if (state.hasFertilizer || state.hasMoisture) ...[
          _sectionTitle('Fertilizer & Soil Reports'),
          _card([
            if (state.hasFertilizer) ...[
              _menuItem(
                icon: 'assets/images/report_menu/fertilizer_report.png',
                title: 'Fertilizer',
                onTap: () => context.push(
                  FertilizerPageRoutes.Fertilizerpage,
                  extra: widget.params,
                ),
              ),
              const _Divider(),
              _menuItem(
                icon: 'assets/images/report_menu/fertilizer_live.png',
                title: 'Fertilizer Live',
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => FertilizerLivePage(
                        deviceId: widget.params['deviceId'].toString(),
                      ),
                    ),
                  );
                },
              ),
              if (state.hasMoisture) const _Divider(),
            ],
            if (state.hasMoisture)
              _menuItem(
                icon: 'assets/images/report_menu/moisture_report.png',
                title: 'Moisture',
                onTap: () => context.push(
                  MoistureReportPageRoutes.Moisturepage,
                  extra: widget.params,
                ),
              ),
          ]),
        ],
        _sectionTitle('System & Greenhouse Reports'),
        _card([
          _menuItem(
            icon: 'assets/images/report_menu/stand_alone.png',
            title: 'Standalone',
            onTap: () => context.push(
              StandaloneReportPageRoutes.Standalonepage,
              extra: widget.params,
            ),
          ),
          if (state.hasFogger) ...[
            const _Divider(),
            _menuItem(
              icon: 'assets/images/report_menu/green_house.png',
              title: 'Green House',
              onTap: () => context.push(
                GreenHouseReportPageRoutes.greenHouseReportPage,
                extra: widget.params,
              ),
            ),
          ],
        ]),
      ],
    );
  }

  Widget _menuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      enabled: enabled,
      leading: Image.asset(
        icon,
        width: 20,
        height: 20,
        color: enabled ? AppThemes.primaryColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: enabled ? Colors.black : Colors.grey,
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        height: 0.5,
        color: Colors.grey,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/livemessage_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/previousday_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/prs_gauge_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/well_level_section.dart';
import '../cubit/dashboard_page_cubit.dart';

class CtrlLivePage extends StatelessWidget {
  final LiveMessageEntity? selectedController;

  const CtrlLivePage({super.key, this.selectedController});

  double _safeParse(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  String _getFertStatus(LiveMessageEntity? ctrl, int index) {
    if (ctrl != null && ctrl.fertStatus.length > index) {
      return ctrl.fertStatus[index];
    }
    return "0";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardPageCubit, DashboardState>(
      builder: (context, state) {
        LiveMessageEntity? liveData = selectedController;

        if (state is DashboardGroupsLoaded && selectedController != null) {
          final controllers = state.groupControllers[state.selectedGroupId];
          if (controllers != null && state.selectedControllerIndex != null) {
            liveData = controllers[state.selectedControllerIndex!].liveMessage;
          }
        }

        if (liveData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isMotorOn = liveData.motorOnOff == "1";
        final bool isValveOn = liveData.valveOnOff == "1";

        return Scaffold(
          backgroundColor: AppThemes.scaffoldBackGround,
          appBar: CustomAppBar(
            title: "CONTROLLER LIVE",
            actions: [
              _buildStatusBadge(isMotorOn),
              const SizedBox(width: 16),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (state is DashboardGroupsLoaded && state.selectedControllerIndex != null) {
                final controllers = state.groupControllers[state.selectedGroupId];
                if (controllers != null) {
                  context.read<DashboardPageCubit>().getLive(controllers[state.selectedControllerIndex!].deviceId);
                }
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(liveData),
                  const SizedBox(height: 20),
                  _buildQuickStats(liveData),
                  const SizedBox(height: 20),
                  _buildMotorValveControl(liveData, isMotorOn, isValveOn),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: "POWER STATUS", icon: Icons.bolt_rounded),
                  const SizedBox(height: 12),
                  _buildPowerStatusCard(context, liveData),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: "IRRIGATION PROGRESS", icon: Icons.timer_outlined),
                  const SizedBox(height: 12),
                  _buildIrrigationProgressCard(liveData),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: "SYSTEM PARAMETERS", icon: Icons.settings_suggest_outlined),
                  const SizedBox(height: 12),
                  _buildSystemParametersCard(liveData),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: "FERTILIZATION", icon: Icons.science_outlined),
                  const SizedBox(height: 12),
                  _buildFertilizationOverview(liveData),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: "ANALYTICS", icon: Icons.analytics_outlined),
                  const SizedBox(height: 12),
                  PreviousDaySection(
                    runTimeToday: liveData.runTimeToday,
                    runTimePrevious: liveData.runTimePrevious,
                    flowToday: liveData.flowToday,
                    flowPrevious: liveData.flowPrevDay,
                    cFlowToday: "0",
                    cFlowPrevious: "0",
                  ),
                  const SizedBox(height: 32),
                  _buildFooterInfo(liveData),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isOn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOn ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOn ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: isOn ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(
            isOn ? "RUNNING" : "STOPPED",
            style: TextStyle(color: isOn ? Colors.green.shade900 : Colors.red.shade900, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(LiveMessageEntity liveData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SYNCED AT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 4),
            Text("${liveData.cd} | ${liveData.ct}", 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: const Icon(Icons.sync_rounded, color: AppThemes.primaryColor, size: 20),
        ),
      ],
    );
  }

  Widget _buildQuickStats(LiveMessageEntity liveData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppThemes.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(liveData.liveDisplay1.toUpperCase(), 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStatItem(Icons.signal_cellular_alt_rounded, "${liveData.signal}%", "Signal"),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              _buildQuickStatItem(Icons.bolt_rounded, "${liveData.ryVoltage}V", "Voltage"),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              _buildQuickStatItem(Icons.battery_std_rounded, "${liveData.batVolt}%", "Battery"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppThemes.primaryColor, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMotorValveControl(LiveMessageEntity liveData, bool isMotorOn, bool isValveOn) {
    final bool status = isMotorOn;

    return _buildSectionCard(
      child: Row(
        children: [
          _buildControlCircle(
            "MOTOR", 
            status ? 'assets/images/common/ui_motor.gif' : 'assets/images/common/live_motor_off.png', 
            status
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  liveData.modeOfOperation.isNotEmpty ? liveData.modeOfOperation : "Manual Mode",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                const Text("CURRENT MODE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildControlCircle(
            "VALVE", 
            status ? 'assets/images/common/valve_open.gif' : 'assets/images/common/valve_stop.png', 
            status
          ),
        ],
      ),
    );
  }

  Widget _buildControlCircle(String label, String asset, bool isOn) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isOn ? Colors.green.shade50 : Colors.red.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: isOn ? Colors.green.shade200 : Colors.red.shade200, width: 2),
          ),
          child: Center(
            child: Image.asset(
              asset, 
              width: 40, 
              height: 40, 
              errorBuilder: (c,e,s) => Icon(Icons.settings_input_component, color: isOn ? Colors.green : Colors.red)
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildPowerStatusCard(BuildContext context, LiveMessageEntity liveData) {
    return _buildSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              _buildPhaseColumn(context, const Color(0xffE21E11), 'R', liveData.rVoltage, liveData.rCurrent, "RY", liveData.ryVoltage),
              _buildPhaseColumn(context, const Color(0xffFEC106), 'Y', liveData.yVoltage, liveData.yCurrent, "YB", liveData.ybVoltage),
              _buildPhaseColumn(context, const Color(0xff6C8DB7), 'B', liveData.bVoltage, liveData.bCurrent, "BR", liveData.brVoltage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseColumn(BuildContext context, Color color, String label, String volt, String current, String l2lLabel, String l2lVolt) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color, 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text("$label Phase", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(width: 40, height: 1, color: Colors.white54),
            const SizedBox(height: 8),
            Text("$volt V", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            const Text("PHASE-N", style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
            const Divider(height: 16, indent: 10, endIndent: 10, color: Colors.white24),
            Text("$current A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            const Text("CURRENT", style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
            const Divider(height: 16, indent: 10, endIndent: 10, color: Colors.white24),
            Text("$l2lVolt V", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            Text(l2lLabel, style: const TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildIrrigationProgressCard(LiveMessageEntity liveData) {
    return _buildSectionCard(
      child: Row(
        children: [
          Expanded(child: _buildProgressItem("SET DURATION", liveData.zoneDuration, Icons.update_rounded)),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(child: _buildProgressItem("REMAINING", liveData.zoneRemainingTime, Icons.hourglass_bottom_rounded)),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppThemes.primaryColor),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSystemParametersCard(LiveMessageEntity liveData) {
    return _buildSectionCard(
      child: Column(
        children: [
          _buildDataGridRow([
            {"label": "PHASE", "value": liveData.phase},
            {"label": "PROGRAM", "value": liveData.programName},
          ]),
          const Divider(height: 32),
          _buildDataGridRow([
            {"label": "ZONE", "value": liveData.zoneNo},
            {"label": "VALVE ID", "value": liveData.valveForZone},
          ]),
          const SizedBox(height: 24),
          PressureGaugeSection(
            prsIn: _safeParse(liveData.prsIn),
            prsOut: _safeParse(liveData.prsOut),
            fertFlow: _safeParse(liveData.flowRate),
          ),
          const SizedBox(height: 24),
          WellLevelSection(
            level: _safeParse(liveData.wellLevel),
            flow: _safeParse(liveData.wellPercent),
          )
        ],
      ),
    );
  }

  Widget _buildDataGridRow(List<Map<String, String>> items) {
    return Row(
      children: items.map((item) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item["label"]!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(item["value"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildFertilizationOverview(LiveMessageEntity liveData) {
    return _buildSectionCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              final isOn = _getFertStatus(liveData, i) == "1";
              final statusColor = isOn ? Colors.green.shade600 : Colors.red.shade600;
              return Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor),
                ),
                child: Center(
                  child: Text("F${i + 1}", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSmallDetailItem("EC ", liveData.ec)),
              const SizedBox(width: 12),
              Expanded(child: _buildSmallDetailItem("PH ", liveData.ph)),
            ],
          ),
          const SizedBox(height: 20),
          // Cleaned up: Removed mis-mapped FERT rates that were showing RTC timers.
          // Real-time fertilization rates are typically monitored via the Fert-Live report.
          const Center(
            child: Text("Monitoring active injection points", 
              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemes.scaffoldBackGround, 
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppThemes.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildFooterInfo(LiveMessageEntity liveData) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: Column(
              children: [
                const Text("FIRMWARE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text("${liveData.versionBoard} | ${liveData.versionModule}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppThemes.primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppThemes.primaryColor),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 0.8)),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}

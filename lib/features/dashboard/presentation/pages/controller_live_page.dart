import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/livemessage_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/previousday_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/prs_gauge_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/well_level_section.dart';
import '../cubit/dashboard_page_cubit.dart';
import '../widgets/ryb_section.dart';

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

  String _getFertValue(LiveMessageEntity? ctrl, int index) {
    if (ctrl != null && ctrl.fertValues.length > index) {
      return ctrl.fertValues[index];
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
        final bool isOnline = true; // Based on latest sync or specific flag if available

        return Scaffold(
          backgroundColor: AppThemes.scaffoldBackGround,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: AppThemes.primaryColor),
            title: const Text("CONTROLLER LIVE", 
              style: TextStyle(color: AppThemes.primaryColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)
            ),
            centerTitle: true,
            actions: [
              _buildStatusBadge(isMotorOn), // Using motor status as general indicator here
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                  RYBSection(
                    r: liveData.rVoltage,
                    y: liveData.yVoltage,
                    b: liveData.bVoltage,
                    c1: liveData.rCurrent,
                    c2: liveData.yCurrent,
                    c3: liveData.bCurrent,
                  ),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppThemes.primaryColor)),
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
        gradient: LinearGradient(
          colors: [AppThemes.primaryColor, AppThemes.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppThemes.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Text(liveData.liveDisplay1.toUpperCase(), 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStatItem(Icons.signal_cellular_alt_rounded, "${liveData.signal}%", "Signal"),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildQuickStatItem(Icons.bolt_rounded, "${liveData.ryVoltage}V", "Voltage"),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildQuickStatItem(Icons.battery_std_rounded, "${liveData.batVolt}V", "Battery"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildMotorValveControl(LiveMessageEntity liveData, bool isMotorOn, bool isValveOn) {
    return _buildSectionCard(
      child: Row(
        children: [
          _buildControlCircle("MOTOR", 'assets/images/common/ui_motor.gif', liveData.motorOnOff == "1"),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  liveData.modeOfOperation.isNotEmpty ? liveData.modeOfOperation : "Manual Mode",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppThemes.primaryColor),
                ),
                const SizedBox(height: 4),
                const Text("CURRENT MODE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildControlCircle("VALVE", 'assets/images/common/valve_open.gif', liveData.valveOnOff == "1"),
        ],
      ),
    );
  }

  Widget _buildControlCircle(String label, String asset, bool isOn) {
    return Column(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: isOn ? Colors.green.shade50 : Colors.red.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: isOn ? Colors.green.shade200 : Colors.red.shade200, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Center(
            child: Opacity(
              opacity: isOn ? 1.0 : 0.5,
              child: Image.asset(asset, width: 45, height: 45, errorBuilder: (c,e,s) => Icon(Icons.settings_input_component, color: isOn ? Colors.green : Colors.red)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
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
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
            Text(item["value"]!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
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
              return Container(
                width: 48,
                height: 40,
                decoration: BoxDecoration(
                  color: isOn ? Colors.green.shade600 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isOn ? Colors.green.shade600 : Colors.grey.shade300),
                  boxShadow: isOn ? [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : null,
                ),
                child: Center(
                  child: Text("F${i + 1}", 
                    style: TextStyle(color: isOn ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSmallDetailItem("EC LEVEL", liveData.ec)),
              const SizedBox(width: 12),
              Expanded(child: _buildSmallDetailItem("PH LEVEL", liveData.ph)),
            ],
          ),
          const SizedBox(height: 20),
          _buildDataGridRow([
            {"label": "FERT-1", "value": _getFertValue(liveData, 0)},
            {"label": "FERT-2", "value": _getFertValue(liveData, 1)},
          ]),
          const SizedBox(height: 16),
          _buildDataGridRow([
            {"label": "FERT-3", "value": _getFertValue(liveData, 2)},
            {"label": "FERT-4", "value": _getFertValue(liveData, 3)},
          ]),
        ],
      ),
    );
  }

  Widget _buildSmallDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppThemes.scaffoldBackGround, borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
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
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.8)),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}

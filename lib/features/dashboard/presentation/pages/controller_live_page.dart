import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/livemessage_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/fertstatus_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/previousday_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/prs_gauge_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/well_level_section.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/app_images.dart';
import '../cubit/dashboard_page_cubit.dart';
import 'package:intl/intl.dart';

class CtrlLivePage extends StatefulWidget {
  final LiveMessageEntity? selectedController;
  final String? deviceId;
  final String? lastSync;

  const CtrlLivePage({super.key, this.selectedController, this.deviceId, this.lastSync});

  @override
  State<CtrlLivePage> createState() => _CtrlLivePageState();
}

class _CtrlLivePageState extends State<CtrlLivePage> with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.deviceId != null) {
      di.sl.get<MqttManager>().subscribe(widget.deviceId!);
      _refreshData();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  double _safeParse(String? value) {
    if (value == null || value.isEmpty || value.toUpperCase() == "NA") return 0.0;
    String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    return double.tryParse(cleanValue) ?? 0.0;
  }

  Future<void> _refreshData() async {
    if (widget.deviceId != null) {
      if (!_refreshController.isAnimating) _refreshController.repeat();
      final mqttManager = di.sl.get<MqttManager>();
      mqttManager.publish(widget.deviceId!, jsonEncode(PublishMessageHelper.requestLive));
      
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _refreshController.stop();
    }
  }

  String getDate({required String dateStr}) {
    try {
      if (dateStr.isEmpty || dateStr == "--") return "--";
      final parts = dateStr.split('/');
      if (parts.length < 3) return dateStr;
      return DateFormat("d/MMM/yyyy").format(DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]))).toUpperCase();
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardPageCubit, DashboardState>(
      builder: (context, state) {
        LiveMessageEntity? liveMessage = widget.selectedController;

        if (state is DashboardGroupsLoaded && widget.deviceId != null) {
          for (var groupControllers in state.groupControllers.values) {
            for (var controller in groupControllers) {
              if (controller.deviceId == widget.deviceId) {
                liveMessage = controller.liveMessage;
                if (_refreshController.isAnimating) _refreshController.stop();
                break;
              }
            }
          }
        }

        if (liveMessage == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppThemes.primaryColor)),
          );
        }

        return Scaffold(
          backgroundColor: AppThemes.scaffoldBackGround,
          appBar: CustomAppBar(
            title: "CONTROLLER LIVE",
            actions: [
              _buildStatusBadge(liveMessage.motorOnOff == "1"),
              const SizedBox(width: 16),
            ],
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification && notification.metrics.pixels < -80) {
                _refreshData();
              }
              return false;
            },
            child: RefreshIndicator(
              color: AppThemes.primaryColor,
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMountainHeader(liveMessage),
                    const SizedBox(height: 10),
                    
                    _buildDashboardCard(
                      child: _buildMotorValveControl(liveMessage),
                    ),
                    const SizedBox(height: 10),

                    _buildDashboardCard(
                      child: _buildPowerMonitoring(liveMessage),
                    ),
                    const SizedBox(height: 10),

                    const _SectionHeader(title: "IRRIGATION PROGRESS", icon: Icons.timer_outlined),
                    _buildDashboardCard(
                      child: Row(
                        children: [
                          _buildProgressItem("SET TIME", liveMessage.zoneDuration, const Color(0xff2E712A), const Color(0xff689F39)),
                          const SizedBox(width: 10),
                          _buildProgressItem("TIME LEFT", liveMessage.zoneRemainingTime, const Color(0xff347CA6), const Color(0xff52AED7)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    const _SectionHeader(title: "SYSTEM PARAMETERS", icon: Icons.settings_suggest_outlined),
                    _buildDashboardCard(
                      child: Column(
                        children: [
                          _buildDataGridRow([
                            {"label": "PHASE", "value": liveMessage.phase},
                            {"label": "PROGRAM", "value": liveMessage.programName},
                          ]),
                          const Divider(height: 32, color: Colors.black12),
                          _buildDataGridRow([
                            {"label": "ZONE", "value": liveMessage.zoneNo},
                            {"label": "VALVE ID", "value": liveMessage.valveForZone},
                          ]),
                          const SizedBox(height: 24),
                          PressureGaugeSection(
                            prsIn: _safeParse(liveMessage.prsIn),
                            prsOut: _safeParse(liveMessage.prsOut),
                            fertFlow: _safeParse(liveMessage.flowRate),
                          ),
                          const SizedBox(height: 24),
                          WellLevelSection(
                            level: _safeParse(liveMessage.wellLevel),
                            flow: _safeParse(liveMessage.wellPercent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    const _SectionHeader(title: "FERTILIZATION STATUS", icon: Icons.science_outlined),
                    _buildDashboardCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Active Injection Points:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) {
                              final isOn = _fert(liveMessage!, i) == "1";
                              return _buildFertCircle("F${i + 1}", isOn);
                            }),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _buildSmallDetailItem("EC LEVEL", liveMessage.ec)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildSmallDetailItem("PH LEVEL", liveMessage.ph)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    const _SectionHeader(title: "FERTILIZER QUANTITIES", icon: Icons.opacity_rounded),
                    _buildDashboardCard(
                      child: Column(
                        children: [
                          _buildDataGridRow([
                            {"label": "FERT-1", "value": _fertVal(liveMessage, 0)},
                            {"label": "FERT-2", "value": _fertVal(liveMessage, 1)},
                          ]),
                          const Divider(height: 24, color: Colors.black12),
                          _buildDataGridRow([
                            {"label": "FERT-3", "value": _fertVal(liveMessage, 2)},
                            {"label": "FERT-4", "value": _fertVal(liveMessage, 3)},
                          ]),
                          const Divider(height: 24, color: Colors.black12),
                          _buildDataGridRow([
                            {"label": "FERT-5", "value": _fertVal(liveMessage, 4)},
                            {"label": "FERT-6", "value": _fertVal(liveMessage, 5)},
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    const _SectionHeader(title: "DAILY PERFORMANCE", icon: Icons.analytics_outlined),
                    _buildDashboardCard(
                      child: PreviousDaySection(
                        runTimeToday: liveMessage.runTimeToday,
                        runTimePrevious: liveMessage.runTimePrevious,
                        flowToday: liveMessage.flowToday,
                        flowPrevious: liveMessage.flowPrevDay,
                        cFlowToday: liveMessage.totalMeterFlow,
                        cFlowPrevious: "0",
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildFooter(liveMessage),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMountainHeader(LiveMessageEntity live) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -10,
            right: -10,
            child: Image.asset(
              height: 80,
              AppImages.mountain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(Icons.signal_cellular_alt, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Signal ${live.signal}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.battery_6_bar_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Battery ${live.batVolt}% | ${getDate(dateStr: live.cd)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                    const SizedBox(width: 8),
                    Text(
                      'Sync At: ${live.cd}, ${live.ct}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _refreshController,
                      builder: (context, child) => InkWell(
                        onTap: _refreshData,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppThemes.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: RotationTransition(
                            turns: _refreshController,
                            child: const Icon(Icons.sync_rounded, color: AppThemes.primaryColor, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotorValveControl(LiveMessageEntity live) {
    final bool isOn = live.motorOnOff == "1";
    return Row(
      children: [
        _buildControlCircle("MOTOR", isOn ? 'assets/images/common/ui_motor.gif' : 'assets/images/common/live_motor_off.png', isOn),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Text(
                live.modeOfOperation.isNotEmpty ? live.modeOfOperation.toUpperCase() : "MANUAL MODE",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              const Text("CURRENT MODE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildControlCircle("VALVE", isOn ? (live.valveOnOff == "1" ? 'assets/images/common/valve_open.gif' : 'assets/images/common/valve_stop.png') : 'assets/images/common/valve_stop.png', live.valveOnOff == "1" && isOn),
      ],
    );
  }

  Widget _buildControlCircle(String label, String asset, bool isOn) {
    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: isOn ? Colors.green.shade50 : Colors.red.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: isOn ? Colors.green.shade200 : Colors.red.shade200, width: 2),
          ),
          child: Center(
            child: Image.asset(asset, width: 40, height: 40, errorBuilder: (c,e,s) => Icon(Icons.settings_input_component, color: isOn ? Colors.green : Colors.red)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildPowerMonitoring(LiveMessageEntity live) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xffFFF5DC),
              ),
              child: Center(
                child: Image.asset(
                  AppImages.currentIcon,
                  width: 25,
                  height: 25,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Power Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 20),
        const Text("PHASE TO NEUTRAL (V)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRYBWidget(backgroundColor: const Color(0xffE21E11), value: live.rVoltage, phase: 'R Phase'),
            _buildRYBWidget(backgroundColor: const Color(0xffFEC106), value: live.yVoltage, phase: 'Y Phase'),
            _buildRYBWidget(backgroundColor: const Color(0xff6C8DB7), value: live.bVoltage, phase: 'B Phase'),
          ],
        ),
        const SizedBox(height: 20),
        const Text("PHASE TO PHASE (V)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRYBWidget(backgroundColor: const Color(0xffE21E11).withOpacity(0.8), value: live.ryVoltage, phase: 'RY Phase'),
            _buildRYBWidget(backgroundColor: const Color(0xffFEC106).withOpacity(0.8), value: live.ybVoltage, phase: 'YB Phase'),
            _buildRYBWidget(backgroundColor: const Color(0xff6C8DB7).withOpacity(0.8), value: live.brVoltage, phase: 'BR Phase'),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xffE1EEEE)
          ),
          child: Column(
            children: [
              const Text("LINE CURRENTS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 8),
              Text(
                'C1: ${live.rCurrent}A | C2: ${live.yCurrent}A | C3: ${live.bCurrent}A',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRYBWidget({required Color backgroundColor, required String value, required String phase}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
        ),
        child: Column(
          children: [
            Text(phase, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),),
            const SizedBox(height: 4),
            Container(width: 30, height: 0.5, color: Colors.white70),
            const SizedBox(height: 4),
            Text('$value V', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }

  Widget _buildFertCircle(String label, bool isOn) {
    return Column(
      children: [
        Container(
          width: 45, height: 45,
          decoration: BoxDecoration(
            color: isOn ? Colors.green : Colors.red,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: (isOn ? Colors.green : Colors.red).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Center(
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(String title, String value, Color titleColor, Color backgroundColor) {
    return Expanded(
      child: Container(
        height: 85,
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(9)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80, height: 35,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12), topLeft: Radius.circular(12)),
                color: titleColor,
              ),
              child: Center(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            )
          ],
        ),
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

  Widget _buildSmallDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemes.scaffoldBackGround, 
        borderRadius: BorderRadius.circular(10),
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

  Widget _buildDashboardCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
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

  Widget _buildFooter(LiveMessageEntity live) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)
        ),
        child: Column(
          children: [
            const Text("FIRMWARE VERSION", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text("${live.versionBoard} | ${live.versionModule}",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppThemes.primaryColor)),
          ],
        ),
      ),
    );
  }

  String _fert(LiveMessageEntity controller, int i) => (controller.fertStatus.length > i) ? controller.fertStatus[i] : "0";
  String _fertVal(LiveMessageEntity controller, int i) => (controller.fertValues.length > i) ? controller.fertValues[i] : "0";
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppThemes.primaryColor),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 0.8)),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

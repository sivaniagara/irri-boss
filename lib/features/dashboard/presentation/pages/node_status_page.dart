import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/node_status_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/get_moisture/utils/get_moisture_status_routes.dart';
import '../../../../core/di/injection.dart';

class NodeStatusPage extends StatefulWidget {
  final int userId, controllerId, subuserId;
  final String deviceId;
  final String motorStatus;

  const NodeStatusPage({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.subuserId,
    required this.deviceId,
    required this.motorStatus,
  });

  @override
  State<NodeStatusPage> createState() => _NodeStatusPageState();
}

class _NodeStatusPageState extends State<NodeStatusPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NodeStatusCubit>()
        ..getNodeStatus(
            userId: widget.userId,
            subUserId: widget.subuserId,
            controllerId: widget.controllerId,
            deviceId: widget.deviceId,
            motorStatus: widget.motorStatus
        ),
      child: Scaffold(
        backgroundColor: AppThemes.scaffoldBackGround,
        appBar: CustomAppBar(
          title: "Node Status",
          actions: [
            Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    final moistureParams = {
                      'userId': widget.userId,
                      'subuserId': widget.subuserId,
                      'controllerId': widget.controllerId,
                      'fromDate': DateTime.now().toString().split(' ')[0],
                      'toDate': DateTime.now().toString().split(' ')[0],
                    };
                    context.push(GetMoistureNodeStatusRoutes.nodeMoistureStatusPage, extra: moistureParams);
                  },
                  tooltip: "Moisture Status",
                  icon: const Icon(Icons.opacity_rounded, color: Colors.blue)
              ),
            ),
            Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    context.read<NodeStatusCubit>().getNodeStatus(
                        userId: widget.userId,
                        subUserId: widget.subuserId,
                        controllerId: widget.controllerId,
                        deviceId: widget.deviceId,
                        isTestComm: true,
                        motorStatus: widget.motorStatus
                    );
                  },
                  tooltip: "Test Communication",
                  icon: const Icon(Icons.wifi_tethering_rounded, color: Colors.black87)
              ),
            ),
            Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  context.read<NodeStatusCubit>().getNodeStatus(
                    userId: widget.userId,
                    subUserId: widget.subuserId,
                    controllerId: widget.controllerId,
                    deviceId: widget.deviceId,
                    motorStatus: widget.motorStatus,
                  );
                },
                tooltip: "Refresh",
                icon: const Icon(Icons.refresh_rounded, color: Colors.black87)
              ),
            ),
          ],
        ),
        body: BlocBuilder<NodeStatusCubit, NodeStatusState>(
          builder: (context, state) {
            if (state is NodeStatusInitialState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NodeStatusFailure) {
              return Center(child: Text(state.message));
            }

            if (state is NodeStatusLoadedState) {
              final nodes = state.nodeStatusEntity;

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: nodes.length,
                itemBuilder: (context, index) {
                  final node = nodes[index];
                  final bool isValveRunning = node.status == "1";
                  final bool isError = node.status == "1" && widget.motorStatus == "0" && node.category.toLowerCase().contains('valve');
                  
                  Color backgroundColor = Colors.white;
                  Color textColor = Colors.black87;
                  String assetPath = '';
                  
                  final cat = node.category.toLowerCase();
                  if (cat.contains('valve')) {
                    if (isError) {
                      backgroundColor = Colors.red;
                      textColor = Colors.white;
                      assetPath = 'assets/images/common/valve_no_communication.png';
                    } else if (isValveRunning) {
                      backgroundColor = Colors.green;
                      textColor = Colors.white;
                      assetPath = 'assets/images/common/valve_open.gif';
                    } else {
                      backgroundColor = Colors.white;
                      assetPath = 'assets/images/common/valve_stop.png';
                    }
                  } else if (cat.contains('moisture')) {
                    assetPath = 'assets/images/icons/moisture_sensor_icon.png';
                  } else if (cat.contains('pressure')) {
                    assetPath = 'assets/images/icons/pressure_gauge_icon.png';
                  } else if (cat.contains('light')) {
                    assetPath = 'assets/images/icons/light_icon.png';
                  } else if (cat.contains('flow')) {
                    assetPath = 'assets/images/icons/flow_meter_icon.png';
                  } else {
                    assetPath = 'assets/images/common/valve_stop.png';
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.05),
                          alignment: Alignment.center,
                          child: Text(
                            isValveRunning && cat.contains('valve') ? 'Z${extractZoneNumber(node.message)}' : node.category.toUpperCase(),
                            style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.settings_input_component, color: textColor.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            children: [
                              Text(
                                node.value.trim().isEmpty ? "--" : node.value.trim(),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                              ),
                              Text(
                                'SN:${node.serialNumber}',
                                style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String extractZoneNumber(String msg) {
    final regex = RegExp(r'(?:ZONE=)?(\d+)\s*OPEN|OPEN\s*(\d+)');
    final match = regex.firstMatch(msg);
    if (match != null) {
      return match.group(1) ?? match.group(2) ?? "0";
    }
    return "0";
  }
}

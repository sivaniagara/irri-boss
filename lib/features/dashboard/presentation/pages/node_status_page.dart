import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/node_status_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:niagara_smart_drip_irrigation/features/get_moisture/utils/get_moisture_status_routes.dart';
import '../../../../core/di/injection.dart';
import '../../utils/node_status_images.dart';

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

class _NodeStatusPageState extends State<NodeStatusPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppThemes.scaffoldBackGround,
            appBar: CustomAppBar(
              title: "Node Status",
              actions: [
                IconButton(
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
                IconButton(
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
                IconButton(
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
              ],
            ),
            body: BlocBuilder<NodeStatusCubit, NodeStatusState>(
              builder: (context, state) {
                if (state is NodeStatusInitialState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NodeStatusFailure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(state.message, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                if (state is NodeStatusLoadedState) {
                  final nodes = state.nodeStatusEntity;

                  if (nodes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.layers_clear_rounded, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            "No nodes found",
                            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<NodeStatusCubit>().getNodeStatus(
                      userId: widget.userId,
                      subUserId: widget.subuserId,
                      controllerId: widget.controllerId,
                      deviceId: widget.deviceId,
                      motorStatus: widget.motorStatus,
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: nodes.length,
                      itemBuilder: (context, index) {
                        final node = nodes[index];
                        final isValveRunning = node.status == "1";
                        final isError = node.status == "1" && widget.motorStatus == "0";
                        
                        final iconPath = isError
                            ? NodeStatusImages.getIcon('valvesErr')
                            : isValveRunning
                                ? NodeStatusImages.getIcon('valvesOn')
                                : NodeStatusImages.getIcon(node.category);
                        
                        final statusColor = NodeStatusImages.getTintColor(node.status);
                        
                        return AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                boxShadow: [
                                  if (isValveRunning || isError)
                                    BoxShadow(
                                      color: (isError ? Colors.red : Colors.green).withOpacity(0.2 * _pulseController.value),
                                      blurRadius: 8 * _pulseController.value,
                                      spreadRadius: 2 * _pulseController.value,
                                    ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                                border: Border.all(
                                  color: isError 
                                      ? Colors.red.withOpacity(0.5 + (0.5 * _pulseController.value)) 
                                      : isValveRunning 
                                          ? Colors.green.withOpacity(0.5 + (0.5 * _pulseController.value)) 
                                          : Colors.grey.shade200,
                                  width: (isValveRunning || isError) ? 1.5 : 1.0,
                                ),
                              ),
                              child: child,
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 24,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: (isError ? Colors.red : statusColor).withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isValveRunning || isError)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isError ? Colors.red : Colors.green,
                                        ),
                                      ),
                                    Flexible(
                                      child: Text(
                                        isValveRunning ? 'Z${extractZoneNumber(node.message)}' : node.category.toUpperCase(),
                                        style: TextStyle(
                                          color: isError ? Colors.red : (isValveRunning ? Colors.green.shade700 : AppThemes.primaryColor),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    iconPath,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      isError ? Colors.red : (isValveRunning ? Colors.green : Colors.grey.shade600),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      node.value.trim().isEmpty ? "--" : node.value.trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SN:${node.serialNumber}',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        }
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

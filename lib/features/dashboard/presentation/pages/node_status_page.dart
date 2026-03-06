import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/node_status_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:niagara_smart_drip_irrigation/features/get_moisture/utils/get_moisture_status_routes.dart';
import '../../../../core/di/injection.dart';
import '../../utils/node_status_images.dart';

class NodeStatusPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NodeStatusCubit>()
        ..getNodeStatus(
            userId: userId,
            subUserId: subuserId,
            controllerId: controllerId,
            deviceId: deviceId,
            motorStatus: motorStatus
        ),
      child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Node Status"),
                actions: [
                  IconButton(
                      onPressed: (){
                        final moistureParams = {
                          'userId': userId,
                          'subuserId': subuserId,
                          'controllerId': controllerId,
                          'fromDate': DateTime.now().toString().split(' ')[0],
                          'toDate': DateTime.now().toString().split(' ')[0],
                        };
                        context.push(GetMoistureNodeStatusRoutes.nodeMoistureStatusPage, extra: moistureParams);
                      },
                      tooltip: "Get Moisture Status",
                      icon: const Icon(Icons.opacity, color: Colors.blue)
                  ),
                  IconButton(
                      onPressed: (){
                        context.read<NodeStatusCubit>().getNodeStatus(
                            userId: userId,
                            subUserId: subuserId,
                            controllerId: controllerId,
                            deviceId: deviceId,
                            isTestComm: true,
                            motorStatus: motorStatus
                        );
                      },
                      icon: const Icon(Icons.wifi)
                  ),
                  IconButton(
                      onPressed: (){
                        context.read<NodeStatusCubit>().getNodeStatus(
                          userId: userId,
                          subUserId: subuserId,
                          controllerId: controllerId,
                          deviceId: deviceId,
                          motorStatus: motorStatus,
                        );
                      },
                      icon: const Icon(Icons.refresh)
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

                    if (nodes.isEmpty) {
                      return const Center(
                        child: Text(
                          "No nodes found",
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<NodeStatusCubit>().getNodeStatus(
                        userId: userId,
                        subUserId: subuserId,
                        controllerId: controllerId,
                        deviceId: deviceId,
                        motorStatus: motorStatus,
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: nodes.length,
                        itemBuilder: (context, index) {
                          final node = nodes[index];
                          final iconPath =
                          (node.status == "1" && motorStatus == "0")
                              ? NodeStatusImages.getIcon('valvesErr')
                              : (node.status == "1" )
                              ? NodeStatusImages.getIcon('valvesOn')
                              : NodeStatusImages.getIcon(node.category);
                          final tintColor = NodeStatusImages.getTintColor(node.status);
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: tintColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    (node.status == "1") ? 'Zone ${extractZoneNumber(node.message)}' : node.category,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      iconPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    node.value.trim(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'SN: ${node.serialNumber}',
                                    style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
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

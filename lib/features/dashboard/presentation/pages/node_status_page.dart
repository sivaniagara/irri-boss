import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/node_status_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_themes.dart';
import '../../utils/node_status_images.dart';
import '../../../get_moisture/utils/get_moisture_status_routes.dart';

class NodeStatusPage extends StatelessWidget {
  final int userId, controllerId, subuserId;
  final String deviceId;

  const NodeStatusPage({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.subuserId,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NodeStatusCubit>()
        ..getNodeStatus(
          userId: userId,
          subUserId: subuserId,
          controllerId: controllerId,
          deviceId: deviceId
        ),
      child: Scaffold(
        backgroundColor: AppThemes.scaffoldBackGround,
        appBar: AppBar(
          title: const Text("Node Status"),
          actions: [
            IconButton(
                onPressed: (){
                  context.read<NodeStatusCubit>().getNodeStatus(
                    userId: userId,
                    subUserId: subuserId,
                    controllerId: controllerId,
                    deviceId: deviceId,
                    isTestComm: true
                  );
                },
                icon: const Icon(Icons.wifi)
            ),
            IconButton(
                onPressed: (){
                  context.push(
                    GetMoistureNodeStatusRoutes.nodeMoistureStatusPage,
                    extra: {
                      "userId": userId,
                      "subuserId": subuserId,
                      "controllerId": controllerId,
                      "fromDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      "toDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    },
                  );
                },
                icon: const Icon(Icons.analytics_outlined)
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
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<NodeStatusCubit>().getNodeStatus(
                  userId: userId,
                  subUserId: subuserId,
                  controllerId: controllerId,
                  deviceId: deviceId,
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes[index];
                    final iconPath = NodeStatusImages.getIcon(node.category);
                    final tintColor = NodeStatusImages.getTintColor(node.status);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: SvgPicture.asset(
                                iconPath,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(tintColor, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            node.value.trim(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            node.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'SN: ${node.serialNumber}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontSize: 10
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
      ),
    );
  }
}

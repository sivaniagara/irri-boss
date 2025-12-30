import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/node_status_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injection.dart';
import '../../utils/node_status_images.dart';

class NodeStatusPage extends StatelessWidget {
  final int userId, controllerId, subuserId;

  const NodeStatusPage({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.subuserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NodeStatusCubit>()
        ..getNodeStatus(
          userId: userId,
          subUserId: subuserId,
          controllerId: controllerId,
        ),
      child: GlassyWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Node Status")),
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
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                return GridView.builder(
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

                    return GlassCard(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(5),
                      margin: EdgeInsets.zero,
                      opacity: 1,
                      blur: 0,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: SvgPicture.asset(
                                iconPath,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(tintColor, BlendMode.modulate),
                              ),
                            ),
                          ),
                          // const SizedBox(height: 12),
                          Text(
                            node.value.trim(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // const SizedBox(height: 6),
                          Text(
                            node.category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'SN: ${node.serialNumber}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
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
      ),
    );
  }
}

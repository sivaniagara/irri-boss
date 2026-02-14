import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_message_helper.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/livemessage_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/no_data.dart';
import '../bloc/get_moisture_status_bloc.dart';
import '../bloc/get_moisture_status_event.dart';
import '../bloc/get_moisture_status_state.dart';
import '../../data/models/get_moisture_status_model.dart';

class NodeStatusPage extends StatefulWidget {
  final int userId;
  final int subuserId;
  final int controllerId;

  const NodeStatusPage({
    super.key,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
  });

  @override
  State<NodeStatusPage> createState() => _NodeStatusPageState();
}

class _NodeStatusPageState extends State<NodeStatusPage> {
  String mqttStatusMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controllerContext = context.read<ControllerContextCubit>().state;
      if (controllerContext is ControllerContextLoaded) {
        sl<MqttManager>().subscribe(controllerContext.deviceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: AppBar(
        title: const Text("Node Status"),
        actions: [
          IconButton(
            onPressed: () {
              final controllerContext = context.read<ControllerContextCubit>().state;
              if (controllerContext is ControllerContextLoaded) {
                sl<MqttManager>().publish(controllerContext.deviceId, PublishMessageHelper.requestNodeStatus);
              }
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          if (mqttStatusMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "MQTT BOX (Live Updates)",
                            style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () => setState(() => mqttStatusMessage = ""),
                        icon: const Icon(Icons.close, color: Colors.white54, size: 14),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mqttStatusMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<GetMoistureStatusBloc, GetMoistureStatusState>(
              builder: (context, state) {
                if (state is GetMoistureStatusLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetMoistureStatusError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        state.message, 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)
                      ),
                    )
                  );
                } else if (state is GetMoistureStatusLoaded) {
                  if (state.nodeStatusModel.data == null || state.nodeStatusModel.data!.isEmpty) {
                    return noDataNew;
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                       context.read<GetMoistureStatusBloc>().add(
                        FetchGetMoistureStatus(
                          userId: widget.userId,
                          subuserId: widget.subuserId,
                          controllerId: widget.controllerId,
                          fromDate: DateTime.now().toString().split(' ')[0], // Example date
                          toDate: DateTime.now().toString().split(' ')[0],
                        ),
                      );
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: state.nodeStatusModel.data!.length,
                      itemBuilder: (context, index) {
                        final node = state.nodeStatusModel.data![index];
                        return NodeStatusCard(node: node);
                      },
                    ),
                  );
                }
                return noDataNew;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NodeStatusCard extends StatelessWidget {
  final GetMoistureNodeData node;

  const NodeStatusCard({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = node.status == "1";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.router, color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.deviceName?.isNotEmpty == true ? node.deviceName! : 'Node Device',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "SN: ${node.serialNumber ?? 'N/A'}",
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(isOnline),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMainData(context, "Moisture 1", "${node.moisture1 ?? '0'}%", Icons.water_drop, Colors.blue),
                    _buildMainData(context, "Moisture 2", "${node.moisture2 ?? '0'}%", Icons.water_drop_outlined, Colors.lightBlue),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(context, "Category", node.category ?? 'N/A', Icons.category_outlined),
                    _buildInfoItem(context, "Pressure", node.pressure ?? '0', Icons.speed_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(context, "Battery", "${node.batteryVolt ?? '0'}V", Icons.battery_charging_full),
                    _buildInfoItem(context, "Solar", "${node.solarVolt ?? '0'}V", Icons.wb_sunny_outlined),
                  ],
                ),
                
                // Latest SMS / Value Section
                if ((node.value != null && node.value!.trim().isNotEmpty) || (node.message != null && node.message!.isNotEmpty)) ...[
                  const Divider(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.message_outlined, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "LATEST SMS / MESSAGE",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (node.value != null && node.value!.trim().isNotEmpty)
                              Text(
                                node.value!.trim(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            if (node.message != null && node.message!.isNotEmpty) ...[
                              if (node.value != null && node.value!.trim().isNotEmpty) 
                                const SizedBox(height: 4),
                              Text(
                                node.message!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOnline ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? "ONLINE" : "OFFLINE",
            style: TextStyle(
              color: isOnline ? Colors.green[700] : Colors.red[700],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainData(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

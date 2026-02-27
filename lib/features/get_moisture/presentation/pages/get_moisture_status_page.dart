import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_message_helper.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Node Network Status",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                final controllerContext = context.read<ControllerContextCubit>().state;
                if (controllerContext is ControllerContextLoaded) {
                  sl<MqttManager>().publish(controllerContext.deviceId, PublishMessageHelper.requestNodeStatus);
                }
              },
              icon: Icon(Icons.refresh_rounded, color: theme.primaryColor, size: 22),
            ),
          )
        ],
      ),
      body: BlocBuilder<GetMoistureStatusBloc, GetMoistureStatusState>(
        builder: (context, state) {
          if (state is GetMoistureStatusLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetMoistureStatusError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message, 
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                    ),
                  ],
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
                    fromDate: DateTime.now().toString().split(' ')[0], 
                    toDate: DateTime.now().toString().split(' ')[0],
                  ),
                );
              },
              child: ListView.builder(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: state.nodeStatusModel.data!.length,
                itemBuilder: (context, index) {
                  final node = state.nodeStatusModel.data![index];
                  return _premiumNodeCard(context, node);
                },
              ),
            );
          }
          return noDataNew;
        },
      ),
    );
  }

  Widget _premiumNodeCard(BuildContext context, GetMoistureNodeData node) {
    final theme = Theme.of(context);
    final isOnline = node.status == "1";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green.withOpacity(0.03) : Colors.red.withOpacity(0.03),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Icon(Icons.router_rounded, color: theme.primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.deviceName?.isNotEmpty == true ? node.deviceName! : 'Wireless Node',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                      ),
                      Text(
                        "Serial: ${node.serialNumber ?? 'N/A'}",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _statusBadge(isOnline),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _moistureMetric(context, "Sensor A", "${node.moisture1 ?? '0'}%", Icons.water_drop_rounded, Colors.blue),
                    _moistureMetric(context, "Sensor B", "${node.moisture2 ?? '0'}%", Icons.water_drop_outlined, Colors.cyan),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoPill(context, "Pressure", "${node.pressure ?? '0'} bar", Icons.speed_rounded),
                    _infoPill(context, "Battery", "${node.batteryVolt ?? '0'}V", Icons.battery_charging_full_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoPill(context, "Category", node.category ?? 'N/A', Icons.category_rounded),
                    _infoPill(context, "Solar", "${node.solarVolt ?? '0'}V", Icons.wb_sunny_rounded),
                  ],
                ),
                
                if ((node.value != null && node.value!.trim().isNotEmpty) || (node.message != null && node.message!.isNotEmpty)) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("SYSTEM TELEMETRY", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.blueGrey, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        if (node.value != null && node.value!.trim().isNotEmpty)
                          Text(
                            node.value!.trim(),
                            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                          ),
                        if (node.message != null && node.message!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            node.message!,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic, height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isOnline) {
    final color = isOnline ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? "LIVE" : "OFFLINE",
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _moistureMetric(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color, letterSpacing: -1),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(BuildContext context, String label, String value, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: Colors.blueGrey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
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

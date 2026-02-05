import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import '../bloc/serial_set_bloc.dart';
import '../bloc/serial_set_event.dart';
import '../bloc/serial_set_state.dart';

class SerialSetCalibrationSheet extends StatelessWidget {
  final String title;
  const SerialSetCalibrationSheet({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final bool isCommon = title.contains('Common');

    return BlocBuilder<SerialSetBloc, SerialSetState>(
      builder: (context, state) {
        if (state is! SerialSetLoaded && state is! SerialSetActionSuccess) {
          return const Center(child: CircularProgressIndicator());
        }

        final entity = (state is SerialSetLoaded) ? state.entity : (state as SerialSetActionSuccess).entity;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  title,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
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
                    child: entity.nodes.isEmpty
                        ? const Center(child: Text("No nodes available"))
                        : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: entity.nodes.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                      itemBuilder: (context, index) {
                        final node = entity.nodes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  node.qrCode,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  node.serialNo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<SerialSetBloc>().add(SendSerialSetMqttEvent(
                                    smsKey: isCommon ? "C002" : "C004", // VIDCALSET or VSERIALSET
                                    extraValue: node.qrCode,
                                    successMessage: "message delivered",
                                  ));
                                },
                                icon: const Icon(Icons.visibility, color: Colors.black, size: 20),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<SerialSetBloc>().add(SendSerialSetMqttEvent(
                                    smsKey: isCommon ? "C001" : "C003", // IDCALSET or #SERIALSET
                                    extraValue: "${node.qrCode},${node.serialNo}",
                                    successMessage: "message delivered",
                                  ));
                                },
                                icon: const Icon(Icons.send_outlined, color: Colors.blue, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomMaterialButton(
                      onPressed: () => context.pop(),
                      title: 'Go Back',
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
}

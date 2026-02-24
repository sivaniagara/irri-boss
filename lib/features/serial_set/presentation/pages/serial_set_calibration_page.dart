import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_themes.dart';
import '../../../../../../core/widgets/custom_material_button.dart';
import '../bloc/serial_set_bloc.dart';
import '../bloc/serial_set_event.dart';
import '../bloc/serial_set_state.dart';

class SerialSetCalibrationSheet extends StatelessWidget {
  const SerialSetCalibrationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SerialSetBloc, SerialSetState>(
      builder: (context, state) {
        if (state is! SerialSetLoaded && state is! SerialSetActionSuccess) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppThemes.scaffoldBackGround,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final entity = (state is SerialSetLoaded) ? state.entity : (state as SerialSetActionSuccess).entity;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppThemes.scaffoldBackGround,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Serial set Calibration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('MAC ID', style: _headerStyle(context))),
                    Expanded(flex: 2, child: Text('SERIAL NO', textAlign: TextAlign.center, style: _headerStyle(context))),
                    SizedBox(width: 90, child: Text('ACTIONS', textAlign: TextAlign.center, style: _headerStyle(context))),
                  ],
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: entity.nodes.isEmpty
                        ? const Center(child: Text("No nodes available"))
                        : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: entity.nodes.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                      itemBuilder: (context, index) {
                        final node = entity.nodes[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  node.qrCode,
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  node.serialNo,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).primaryColor),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ActionButton(
                                    icon: Icons.visibility_outlined,
                                    color: Colors.blueGrey,
                                    onPressed: () {
                                      context.read<SerialSetBloc>().add(SendSerialSetMqttEvent(
                                        smsKey: "C004", // VSERIALSET
                                        extraValue: node.serialNo,
                                        successMessage: "Request sent successfully",
                                      ));
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  _ActionButton(
                                    icon: Icons.send_rounded,
                                    color: Colors.blue,
                                    onPressed: () {
                                      context.read<SerialSetBloc>().add(SendSerialSetMqttEvent(
                                        smsKey: "C003", // #SERIALSET
                                        extraValue: node.serialNo,
                                        successMessage: "Command sent successfully",
                                      ));
                                    },
                                  ),
                                ],
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
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomMaterialButton(
                      onPressed: () => context.pop(),
                      title: 'Close',
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

  TextStyle _headerStyle(BuildContext context) => Theme.of(context).textTheme.labelSmall!.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
    letterSpacing: 0.5,
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

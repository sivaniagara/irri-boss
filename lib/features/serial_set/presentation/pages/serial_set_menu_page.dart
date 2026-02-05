import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/widgets/app_alerts.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../bloc/serial_set_bloc.dart';
import '../bloc/serial_set_event.dart';
import '../bloc/serial_set_state.dart';
import 'serial_set_calibration_page.dart';

class SerialSetMenuPage extends StatelessWidget {
  const SerialSetMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;

    return BlocProvider(
      create: (context) => sl<SerialSetBloc>()..add(FetchSerialSetEvent(
        userId: controllerContext.userId,
        controllerId: controllerContext.controllerId,
        subUserId: controllerContext.subUserId,
        deviceId: controllerContext.deviceId,
      )),
      child: BlocListener<SerialSetBloc, SerialSetState>(
        listener: (context, state) {
          if (state is SerialSetActionSuccess) {
            showSuccessAlert(
              context: context,
              message: state.message,
            );
          } else if (state is SerialSetError) {
            showErrorAlert(context: context, message: state.message);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFE8F1F1),
          appBar: const CustomAppBar(title: 'Serial set'),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocBuilder<SerialSetBloc, SerialSetState>(
              builder: (context, state) {
                if (state is SerialSetLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                String loraValue = '';
                if (state is SerialSetLoaded) {
                  loraValue = state.entity.loraKey;
                } else if (state is SerialSetActionSuccess) {
                  loraValue = state.entity.loraKey;
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        title: 'Serial Set',
                        icon: Icons.chevron_right,
                        onTap: () => _showSheet(context, 'Serial set Calibration'),
                      ),
                      _buildMenuItem(
                        title: 'Set Serial',
                        icon: Icons.visibility,
                        onTap: () {
                          context.read<SerialSetBloc>().add(const SendSerialSetMqttEvent(
                            smsKey: "C005",
                            successMessage: "message delivered",
                          ));
                        },
                      ),
                      _buildMenuItem(
                        title: 'Clear Serial',
                        icon: Icons.visibility,
                        onTap: () {
                          context.read<SerialSetBloc>().add(const SendSerialSetMqttEvent(
                            smsKey: "C006",
                            successMessage: "message delivered",
                          ));
                        },
                      ),
                      _buildMenuItem(
                        title: 'Common Calibration',
                        icon: Icons.chevron_right,
                        onTap: () => _showSheet(context, 'Common Calibration'),
                      ),
                      _LoraKeyTile(initialValue: loraValue),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  void _showSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<SerialSetBloc>(),
          child: SerialSetCalibrationSheet(title: title),
        );
      },
    );
  }
}

class _LoraKeyTile extends StatefulWidget {
  final String initialValue;
  const _LoraKeyTile({required this.initialValue});

  @override
  State<_LoraKeyTile> createState() => _LoraKeyTileState();
}

class _LoraKeyTileState extends State<_LoraKeyTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _LoraKeyTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text && widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'LORA Key value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: 80,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, height: 1.0),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => context.read<SerialSetBloc>().add(UpdateLoraKeyEvent(val)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              context.read<SerialSetBloc>().add(SendSerialSetMqttEvent(
                smsKey: "C008",
                extraValue: _controller.text,
                successMessage: "message delivered",
              ));
            },
            icon: const Icon(Icons.send_outlined, color: Colors.blue, size: 28),
          ),
        ],
      ),
    );
  }
}

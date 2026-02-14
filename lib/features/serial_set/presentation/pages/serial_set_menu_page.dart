import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/theme/app_themes.dart';
import '../../../../../../core/widgets/app_alerts.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/custom_list_tile.dart';
import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../bloc/serial_set_bloc.dart';
import '../bloc/serial_set_event.dart';
import '../bloc/serial_set_state.dart';
import 'serial_set_calibration_page.dart';
import 'common_calibration_page.dart';

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
          backgroundColor: AppThemes.scaffoldBackGround,
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

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    CustomListTile(
                      onTap: () => _showSerialSetSheet(context),
                      title: 'Serial Set',
                      iconData: Icons.chevron_right,
                    ),
                    CustomListTile(
                      onTap: () {
                        context.read<SerialSetBloc>().add(const SendSerialSetMqttEvent(
                          smsKey: "C005", // #SETSERIAL
                          successMessage: "message delivered",
                        ));
                      },
                      title: 'Set Serial',
                      iconData: Icons.visibility,
                    ),
                    CustomListTile(
                      onTap: () {
                        context.read<SerialSetBloc>().add(const SendSerialSetMqttEvent(
                          smsKey: "C006", // #CLEARSERIAL
                          successMessage: "message delivered",
                        ));
                      },
                      title: 'Clear Serial',
                      iconData: Icons.visibility,
                    ),
                    CustomListTile(
                      onTap: () => _showCommonSheet(context),
                      title: 'Common Calibration',
                      iconData: Icons.chevron_right,
                    ),
                    _LoraKeyTile(initialValue: loraValue),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSerialSetSheet(BuildContext context) {
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
          child: const SerialSetCalibrationSheet(),
        );
      },
    );
  }

  void _showCommonSheet(BuildContext context) {
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
          child: const CommonCalibrationSheet(),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'LORA Key value',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              onChanged: (val) => context.read<SerialSetBloc>().add(UpdateLoraKeyEvent(val)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              final value = _controller.text.padLeft(3, '0');
              context.read<SerialSetBloc>().add(SendSerialSetMqttEvent(
                smsKey: "C008",
                extraValue: value,
                successMessage: "message delivered",
              ));
            },
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

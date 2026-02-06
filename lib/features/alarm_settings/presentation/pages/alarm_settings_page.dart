import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_switch.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/leaf_box.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/tiny_text_form_field.dart';
import '../../../../core/services/time_picker_service.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';

class AlarmSettingsPage extends StatelessWidget {
  const AlarmSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Alarm"),
      body: BlocConsumer<AlarmBloc, AlarmState>(
        listener: (context, state) {
          if (state is AlarmSuccess) {
            showSuccessAlert(
              context: context,
              message: state.message,
              onPressed: () => context.pop(), // Only close the alert dialog
            );
          } else if (state is AlarmError) {
            showErrorAlert(context: context, message: state.message);
          }
        },
        buildWhen: (previous, current) =>
            current is AlarmLoaded ||
            current is AlarmError ||
            current is AlarmInitial ||
            current is AlarmLoading,
        builder: (context, state) {
          if (state is AlarmLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlarmLoaded || state is AlarmSuccess) {
            final data = state is AlarmLoaded 
                ? state.entity.alarmData 
                : (state as AlarmSuccess).data.alarmData;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Alarm Settings",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          _buildDropdownRow(
                            context,
                            label: "Alarm Type",
                            value: data.alarmType,
                            items: const {
                              "0": "Timer",
                              "1": "HIGH FLOW",
                              "2": "LOW FLOW",
                              "3": "NO FLOW",
                              "4": "EC HIGH",
                              "5": "EC LOW",
                              "6": "PH HIGH",
                              "7": "PH LOW",
                            },
                            onChanged: (val) => context
                                .read<AlarmBloc>()
                                .add(UpdateAlarmFieldEvent(alarmType: val)),
                          ),
                          _divider(),
                          _buildSwitchRow(
                            context,
                            label: "Alarm Activate",
                            value: data.alarmActive == "1",
                            onChanged: (val) => context.read<AlarmBloc>().add(
                                UpdateAlarmFieldEvent(
                                    alarmActive: val == true ? "1" : "0")),
                          ),
                          _divider(),
                          _buildTimePickerRow(
                            context,
                            label: "Alarm Delay",
                            value: (data.minutes == "0" ||
                                        data.minutes == "00") &&
                                    (data.seconds == "0" ||
                                        data.seconds == "00")
                                ? "00:00"
                                : "${data.minutes.padLeft(2, '0')}:${data.seconds.padLeft(2, '0')}",
                            onTap: () async {
                              final initialTime =
                                  "00:${data.minutes.padLeft(2, '0')}:${data.seconds.padLeft(2, '0')}";
                              final result = await TimePickerService.show(
                                context: context,
                                initialTime: initialTime,
                              );
                              if (result != null) {
                                final parts = result.split(':');
                                if (parts.length >= 3 && context.mounted) {
                                  context.read<AlarmBloc>().add(
                                          UpdateAlarmFieldEvent(
                                        minutes: parts[1],
                                        seconds: parts[2],
                                      ));
                                }
                              }
                            },
                          ),
                          _divider(),
                          _buildSwitchRow(
                            context,
                            label: "Irrigation Stop",
                            value: data.irrigationStop == "1",
                            onChanged: (val) => context.read<AlarmBloc>().add(
                                UpdateAlarmFieldEvent(
                                    irrigationStop: val == true ? "1" : "0")),
                          ),
                          _divider(),
                          _buildSwitchRow(
                            context,
                            label: "Dosing Stop",
                            value: data.dosingStop == "1",
                            onChanged: (val) => context.read<AlarmBloc>().add(
                                UpdateAlarmFieldEvent(
                                    dosingStop: val == true ? "1" : "0")),
                          ),
                          _divider(),
                          _buildInputRow(
                            context,
                            label: "Set Threshold For Alarm",
                            value: data.threshold,
                            onChanged: (val) => context
                                .read<AlarmBloc>()
                                .add(UpdateAlarmFieldEvent(threshold: val)),
                          ),
                          _divider(),
                          _buildSwitchRow(
                            context,
                            label: "Rest After Complete",
                            value: data.reset == "1",
                            onChanged: (val) => context.read<AlarmBloc>().add(
                                UpdateAlarmFieldEvent(
                                    reset: val == true ? "1" : "0")),
                          ),
                          _divider(),
                          _buildTimePickerRow(
                            context,
                            label: "Duration For Auto Rest",
                            value: data.hour.padLeft(2, '0'),
                            onTap: () async {
                              final initialTime =
                                  "${data.hour.padLeft(2, '0')}:00:00";
                              final result = await TimePickerService.show(
                                context: context,
                                initialTime: initialTime,
                              );
                              if (result != null) {
                                final parts = result.split(':');
                                if (parts.length >= 3 && context.mounted) {
                                  context.read<AlarmBloc>().add(
                                          UpdateAlarmFieldEvent(
                                        hour: parts[0],
                                      ));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context
                            .read<AlarmBloc>()
                            .add(const SaveAlarmSettingsEvent()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text("SEND",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          if (state is AlarmError) {
            return Center(
                child:
                    Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }

  Widget _buildDropdownRow(BuildContext context,
      {required String label,
      required String value,
      required Map<String, String> items,
      required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.containsKey(value) ? value : items.keys.first,
              items: items.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(BuildContext context,
      {required String label,
      required bool value,
      required void Function(dynamic) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
          SizedBox(
            width: 65,
            child: CustomSwitch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(BuildContext context,
      {required String label,
      required String value,
      required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
          SizedBox(
            width: 150,
            child: LeafBox(
              child: TinyTextFormField(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerRow(BuildContext context,
      {required String label, required String value, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
          SizedBox(
            width: 150,
            child: GestureDetector(
              onTap: onTap,
              child: LeafBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.black)),
                    Text('HH:MM',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 10,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

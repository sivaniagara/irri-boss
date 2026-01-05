import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/gradiant_background.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/widgets/setting_row.dart';

import '../../../../core/services/time_picker_service.dart';
import '../../domain/entities/common_setting_group_entity.dart';
import '../../domain/entities/common_setting_item_entity.dart';
import '../bloc/template_irrigation_settings_bloc.dart';

class TemplateSettingPage extends StatelessWidget {
  final String appBarTitle;
  const TemplateSettingPage({super.key, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appBarTitle.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState>(
          builder: (context, state){
            if (state is TemplateIrrigationSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TemplateIrrigationSettingsLoaded) {
              return _buildTemplateSettings(context, state);
            } else if (state is ValveFlowLoaded) {
              return _buildValveFlowSettings(context, state);
            } else if (state is TemplateIrrigationSettingsFailure) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text("No Data Available"));
            }
          },
          listener: (context, state){
            if (state is SettingUpdateSuccess) {
              _showFloatingSnackBar(context, state.message);
            } else if (state is TemplateIrrigationSettingsFailure) {
              _showFloatingSnackBar(context, state.message, isError: true);
            }
          }
      ),
    );
  }

  Widget _buildTemplateSettings(BuildContext context, TemplateIrrigationSettingsLoaded state) {
    return GradiantBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ...List.generate(state.controllerIrrigationSettingEntity.settings.length, (groupIndex){
                    CommonSettingGroupEntity commonSettingGroupEntity = state.controllerIrrigationSettingEntity.settings[groupIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(commonSettingGroupEntity.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 8,),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white
                          ),
                          child: Column(
                            children: [
                              ...List.generate(commonSettingGroupEntity.sets.length, (index){
                                CommonSettingItemEntity setting = commonSettingGroupEntity.sets[index];
                                if(setting is SingleSettingItemEntity){
                                  return Column(
                                    children: [
                                      BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                          selector: (state){
                                            if (state is! TemplateIrrigationSettingsLoaded) return '';
                                            return (state
                                                .controllerIrrigationSettingEntity
                                                .settings[groupIndex]
                                                .sets[index] as SingleSettingItemEntity)
                                                .value;
                                          },
                                          builder: (context, value){
                                            return SettingRow(
                                              singleSettingItemEntity: setting,
                                              hideSendButton: false,
                                              onChanged: (val) {
                                                context.read<TemplateIrrigationSettingsBloc>().add(
                                                    UpdateSingleSettingRowEvent(
                                                        groupIndex: groupIndex,
                                                        index: index,
                                                        value: setting.widgetType == 2 ? (val ? 'ON': 'OF') : val
                                                    )
                                                );
                                              },
                                              onTap: () async{
                                                final result = await TimePickerService.show(
                                                    context: context,
                                                    initialTime: setting.value
                                                );
                                                if (result != null && context.mounted) {
                                                  context.read<TemplateIrrigationSettingsBloc>().add(
                                                      UpdateSingleSettingRowEvent(
                                                          groupIndex: groupIndex,
                                                          index: index,
                                                          value: result
                                                      )
                                                );
                                                }
                                              },
                                            );
                                          }
                                      ),
                                      if (index < commonSettingGroupEntity.sets.length - 1)
                                        Divider(color: Colors.grey.shade300,)
                                    ],
                                  );
                                } else if (setting is MultipleSettingItemEntity) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            ...List.generate(setting.listOfSingleSettingItemEntity.length, (multipleIndex) {
                                              return BlocSelector<TemplateIrrigationSettingsBloc, TemplateIrrigationSettingsState, String>(
                                                selector: (state) {
                                                  if (state is! TemplateIrrigationSettingsLoaded) return '';
                                                  final groups = state.controllerIrrigationSettingEntity.settings;
                                                  final item = groups[groupIndex].sets[index] as MultipleSettingItemEntity;
                                                  return item.listOfSingleSettingItemEntity[multipleIndex].value;
                                                },
                                                builder: (context, currentValue) {
                                                  final childEntity = setting.listOfSingleSettingItemEntity[multipleIndex];
                                                  return SettingRow(
                                                    singleSettingItemEntity: childEntity,
                                                    hideSendButton: true,
                                                    onChanged: (val) {
                                                      context.read<TemplateIrrigationSettingsBloc>().add(
                                                        UpdateMultipleSettingRowEvent(
                                                          groupIndex: groupIndex,
                                                          multipleIndex: index,
                                                          index: multipleIndex,
                                                          value: childEntity.widgetType == 2
                                                              ? (val == true ? 'ON' : 'OF')
                                                              : val.toString(),
                                                        ),
                                                      );
                                                    },
                                                    onTap: childEntity.widgetType == 3 ? () async {
                                                      final result = await TimePickerService.show(
                                                        context: context,
                                                        initialTime: childEntity.value,
                                                      );
                                                      if (result != null && context.mounted) {
                                                        context.read<TemplateIrrigationSettingsBloc>().add(
                                                          UpdateMultipleSettingRowEvent(
                                                            groupIndex: groupIndex,
                                                            multipleIndex: index,
                                                            index: multipleIndex,
                                                            value: result,
                                                          ),
                                                        );
                                                      }
                                                    } : null,
                                                  );
                                                },
                                              );
                                            })
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: (){
                                          // TODO: Implement batch send for multiple setting
                                        },
                                        icon: Icon(Icons.send_outlined, color: Theme.of(context).primaryColor,),
                                        style: ButtonStyle(
                                            backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColorLight.withAlpha(76))
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              })
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,)
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _buildValveFlowSettings(BuildContext context, ValveFlowLoaded state) {
    const double inputWidth = 85.0;
    const double buttonWidth = 75.0;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFF64B5F6)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "VALVE FLOW VALUE AND PERCENT",
                  style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Deviation Control with Send Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: const Text(
                        "Deviation Settings",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              "COMMON DEVIATION (%)",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: inputWidth,
                            child: _ValveFlowInputField(
                              initialValue: state.valveFlowEntity.flowDeviation,
                              onChanged: (val) {
                                context.read<TemplateIrrigationSettingsBloc>().add(
                                  UpdateCommonFlowDeviationEvent(deviation: val),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: buttonWidth,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<TemplateIrrigationSettingsBloc>().add(
                                  SaveValveFlowSettingsEvent(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0288D1),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Text(
                                "SEND",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Separate Node Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.valveFlowEntity.nodes.length,
                itemBuilder: (context, index) {
                  final node = state.valveFlowEntity.nodes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${node.serialNo} ${node.nodeName.isEmpty ? 'Valve' : node.nodeName}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "ID: ${node.nodeId}", 
                                  style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Flow Value", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: inputWidth,
                              child: _ValveFlowInputField(
                                initialValue: node.nodeValue,
                                onChanged: (val) {
                                  context.read<TemplateIrrigationSettingsBloc>().add(
                                    UpdateValveFlowNodeEvent(index: index, nodeValue: val),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1.0),
                          child: SizedBox(
                            width: buttonWidth,
                            height: 35, 
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<TemplateIrrigationSettingsBloc>().add(
                                  SendValveFlowSmsEvent(index: index),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0288D1),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Text(
                                "SEND", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFloatingSnackBar(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.55,
        left: 50,
        right: 50,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? Colors.red.withValues(alpha: 0.9) : const Color(0xFF2E7D32).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }
}

class _ValveFlowInputField extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  const _ValveFlowInputField({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_ValveFlowInputField> createState() => _ValveFlowInputFieldState();
}

class _ValveFlowInputFieldState extends State<_ValveFlowInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _ValveFlowInputField oldWidget) {
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
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: widget.onChanged,
      onTap: () {
        if (_controller.text == '0') {
          _controller.clear();
        }
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
        ),
      ),
    );
  }
}

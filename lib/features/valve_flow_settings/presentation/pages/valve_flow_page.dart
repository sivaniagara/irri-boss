import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';
import '../bloc/valve_flow_bloc.dart';
import '../bloc/valve_flow_event.dart';
import '../bloc/valve_flow_state.dart';

class ValveFlowPage extends StatelessWidget {
  const ValveFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Flow Valve and Percentage",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_rounded, color: Color(0xFF263238)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<ValveFlowBloc, ValveFlowState>(
        listener: (context, state) {
          if (state is ValveFlowSuccess) {
            showSuccessAlert(context: context, message: state.message);
          } else if (state is ValveFlowError) {
            showErrorAlert(context: context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ValveFlowLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (state is ValveFlowLoaded || state is ValveFlowSuccess) {
            final entity = (state is ValveFlowLoaded)
                ? state.entity
                : (state as ValveFlowSuccess).data;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Flow Percentage",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Flow Deviation (%)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: _ValveFlowInputField(
                              initialValue: entity.flowDeviation,
                              suffix: "%",
                              onChanged: (val) {
                                context.read<ValveFlowBloc>().add(
                                    UpdateCommonFlowDeviationEvent(deviation: val));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              context.read<ValveFlowBloc>().add(SaveCommonDeviationEvent());
                            },
                            icon: const Icon(Icons.send_outlined, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Flow Valve",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: entity.nodes.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Color(0xFFEEEEEE),
                          ),
                          itemBuilder: (context, index) {
                            final node = entity.nodes[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility_outlined,
                                      color: Color(0xFF263238), size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                              text: node.serialNo.length > 9
                                                  ? "${node.serialNo.substring(0, 9)}... "
                                                  : "${node.serialNo} "),
                                          TextSpan(
                                            text: node.nodeId.padLeft(3, '0'),
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 75,
                                    height: 35,
                                    child: _ValveFlowInputField(
                                      initialValue: node.nodeValue,
                                      onChanged: (val) {
                                        context.read<ValveFlowBloc>().add(
                                            UpdateValveFlowNodeEvent(
                                                index: index, nodeValue: val));
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      context.read<ValveFlowBloc>().add(
                                          SendValveFlowSmsEvent(index: index));
                                    },
                                    icon: const Icon(Icons.send_outlined, color: Colors.blue),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          } else if (state is ValveFlowError) {
            return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _ValveFlowInputField extends StatefulWidget {
  final String initialValue;
  final String? suffix;
  final Function(String) onChanged;

  const _ValveFlowInputField({
    required this.initialValue,
    this.suffix,
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
    // Only update if the value actually changed from the outside
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
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
      style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        isDense: true,
        suffixText: widget.suffix,
        suffixStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
    );
  }
}

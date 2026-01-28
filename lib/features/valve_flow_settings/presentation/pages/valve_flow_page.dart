import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/tiny_text_form_field.dart';
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
<<<<<<< HEAD
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
=======
                    const SizedBox(height: 10),
                    // Deviation Settings
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
                                children: [
                                  const Expanded(
                                    child: Text(
<<<<<<< HEAD
                                      "FLOW DEVIATION (%)",
=======
                                      "COMMON DEVIATION (%)",
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 85,
                                    child: _ValveFlowInputField(
<<<<<<< HEAD
                                      initialValue: entity.flowDeviation
                                      ,
=======
                                      initialValue: entity.flowDeviation,
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
                                      onChanged: (val) {
                                        context.read<ValveFlowBloc>().add(UpdateCommonFlowDeviationEvent(deviation: val));
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 75,
                                    height: 35,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.read<ValveFlowBloc>().add(SaveCommonDeviationEvent());
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
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
                        ),
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
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline)
                            ),
                            child: TinyTextFormField(
                                value: entity.flowDeviation,
                                suffixText: '%', // Added % back as dynamic suffix
                                onChanged: (val) {
                                  context.read<ValveFlowBloc>().add(
                                      UpdateCommonFlowDeviationEvent(deviation: val));
                                }
                            ),
                          ),
                          const SizedBox(width: 24),
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
                      child: ListView.separated(
                        itemCount: entity.nodes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final node = entity.nodes[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
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
<<<<<<< HEAD
                                Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
=======
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
<<<<<<< HEAD
                                    const Text("Flow Value", style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
=======
                                    const Text("Flow Value", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
                                    const SizedBox(height: 2),
                                    SizedBox(
                                      width: 85,
                                      child: _ValveFlowInputField(
                                        initialValue: node.nodeValue,
                                        onChanged: (val) {
                                          context.read<ValveFlowBloc>().add(UpdateValveFlowNodeEvent(index: index, nodeValue: val));
                                        },
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
                                      ),
                                      border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline)
                                  ),
                                  child: TinyTextFormField(
                                      value: node.nodeValue,
                                      suffixText: '',
                                      onChanged: (val) {
                                        context.read<ValveFlowBloc>().add(
                                            UpdateValveFlowNodeEvent(
                                                index: index, nodeValue: val));
                                      }
                                  ),
                                ),
                                const SizedBox(width: 24),
                                IconButton(
                                  onPressed: () {
                                    context.read<ValveFlowBloc>().add(
                                        SendValveFlowSmsEvent(index: index));
                                  },
                                  icon: const Icon(Icons.send_outlined, color: Colors.blue),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        },
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
<<<<<<< HEAD
=======

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
<<<<<<< HEAD
              color: isError ? Colors.red.withValues(alpha: 0.9) : Colors.green.withValues(alpha: 0.9),
=======
              color: isError ? Colors.red.withValues(alpha: 0.9) : const Color(0xFF2E7D32).withValues(alpha: 0.9),
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
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
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
}

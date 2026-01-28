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
                    const SizedBox(height: 8),
                    Container(
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
}

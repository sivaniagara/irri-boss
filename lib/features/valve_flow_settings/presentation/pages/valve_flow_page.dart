import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_images.dart';
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
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Flow & Valve Control",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: BlocBuilder<ValveFlowBloc, ValveFlowState>(
        builder: (context, state) {
          if (state is ValveFlowLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ValveFlowLoaded || state is ValveFlowSuccess) {
            final entity = (state is ValveFlowLoaded)
                ? state.entity
                : (state as ValveFlowSuccess).data;

            return BlocListener<ValveFlowBloc, ValveFlowState>(
              listener: (context, state) {
                if (state is ValveFlowSuccess) {
                  showSuccessAlert(context: context, message: state.message);
                } else if (state is ValveFlowError) {
                  showErrorAlert(context: context, message: state.message);
                }
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildSectionHeader("Configuration"),
                      const SizedBox(height: 8),
                      _buildDeviationCard(context, entity.flowDeviation),
                      const SizedBox(height: 20),
                      _buildSectionHeader("Valve Nodes"),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: entity.nodes.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final node = entity.nodes[index];
                            return _buildValveNodeCard(context, node, index);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black45,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildDeviationCard(BuildContext context, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.analytics_outlined, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Flow Deviation",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Sensitivity percentage",
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            child: Center(
              child: TinyTextFormField(
                value: value,
                suffixText: '%',
                onChanged: (val) {
                  context.read<ValveFlowBloc>().add(
                      UpdateCommonFlowDeviationEvent(deviation: val));
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          _buildSendButton(onPressed: () {
            context.read<ValveFlowBloc>().add(SaveCommonDeviationEvent());
          }),
        ],
      ),
    );
  }

  Widget _buildValveNodeCard(BuildContext context, dynamic node, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              AppImages.valveIcon,
              width: 20,
              height: 20,
              color: AppThemes.primaryColor,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.settings_input_component,
                color: AppThemes.primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.serialNo.length > 15
                      ? "${node.serialNo.substring(0, 15)}..."
                      : node.serialNo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Node ID: ${node.nodeId.padLeft(3, '0')}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            child: Center(
              child: TinyTextFormField(
                value: node.nodeValue,
                onChanged: (val) {
                  context.read<ValveFlowBloc>().add(
                      UpdateValveFlowNodeEvent(index: index, nodeValue: val));
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          _buildSendButton(onPressed: () {
            context.read<ValveFlowBloc>().add(SendValveFlowSmsEvent(index: index));
          }),
        ],
      ),
    );
  }

  Widget _buildSendButton({required VoidCallback onPressed}) {
    return Material(
      color: AppThemes.primaryColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

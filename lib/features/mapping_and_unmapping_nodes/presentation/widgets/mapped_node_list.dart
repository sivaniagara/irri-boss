import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_outlined_button.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/mapped_node_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/bloc/mapping_and_unmapping_nodes_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/enums/delete_mapped_node_enum.dart';

import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../enums/resend_command_enum.dart';
import '../enums/view_command_enum.dart';


class MappedNodeList extends StatefulWidget {
  const MappedNodeList({
    super.key,
  });

  @override
  State<MappedNodeList> createState() => _MappedNodeListState();
}

class _MappedNodeListState extends State<MappedNodeList> {
  late List<MappedNodeEntity> listOfMappedNode;
  bool payloadSending = false;


  @override
  void initState() {
    super.initState();
    final currentState = context.read<MappingAndUnmappingNodesBloc>().state as MappingAndUnmappingNodesLoaded;
    listOfMappedNode = currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.map(((e){
      return e.copyWidth();
    })).toList();
    context.read<MappingAndUnmappingNodesBloc>().add(UpdateResendStatusToIdle());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MappingAndUnmappingNodesBloc, MappingAndUnmappingNodesState>(
        listener: (context, state){
          if(state is MappingAndUnmappingNodesLoaded && state.deleteMappedNodeEnum == DeleteMappedNodeEnum.loading){
            showGradientLoadingDialog(context);
          }else if(state is MappingAndUnmappingNodesLoaded && state.deleteMappedNodeEnum == DeleteMappedNodeEnum.failure){
            context.pop();
            showErrorAlert(context: context, message: state.message);
          }else if(state is MappingAndUnmappingNodesLoaded && state.deleteMappedNodeEnum == DeleteMappedNodeEnum.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: state.deleteMappedNodeEnum.getMessage(),
                onPressed: (){
                  context.pop();
                }
            );
          }else if(state is MappingAndUnmappingNodesLoaded && state.viewCommandEnum == ViewCommandEnum.loading){
            showGradientLoadingDialog(context);
          }else if(state is MappingAndUnmappingNodesLoaded && state.viewCommandEnum == ViewCommandEnum.failure){
            context.pop();
            showErrorAlert(context: context, message: state.message);
          }else if(state is MappingAndUnmappingNodesLoaded && state.viewCommandEnum == ViewCommandEnum.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: state.viewCommandEnum.getMessage(),
                onPressed: (){
                  context.pop();
                }
            );
          }
          // We intentionally DO NOT handle ResendMultipleNodeDetailsMqttEvent status here 
          // because we want to show it in the list tile, not in an alert box.
        },
      child: BlocBuilder<MappingAndUnmappingNodesBloc, MappingAndUnmappingNodesState>(
          builder: (context, state){
            if(state is MappingAndUnmappingNodesLoaded){
              // Sync with Bloc state to get individual node statuses
              listOfMappedNode = state.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity;

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Mapped Nodes',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: listOfMappedNode.isNotEmpty
                          ? ListView.builder(
                        itemCount: listOfMappedNode.length,
                        itemBuilder: (context, index) {
                          final node = listOfMappedNode[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Checkbox(
                                  value: node.select,
                                  onChanged: (bool? value) {
                                    if(!payloadSending){
                                      setState(() {
                                        node.select = value ?? false;
                                      });
                                    }
                                  },
                                ),
                                onTap: (){
                                  _showNodeDetailsBottomSheet(context, node);
                                },
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        node.serialNo ?? "—",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      node.qrCode ?? '—',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blueGrey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${node.categoryName ?? "—"}  •  ${node.userName ?? "—"}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _getStatusWidget(node.status), // Show status in list tile trailing
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined),
                                      tooltip: "View Details",
                                      onPressed: () {
                                        context.read<MappingAndUnmappingNodesBloc>().add(ViewNodeDetailsMqttEvent(mappedNodeEntity: node));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.link_off_rounded),
                                      tooltip: "Unmap Node",
                                      onPressed: () {
                                        final controllerContext =
                                        context.read<ControllerContextCubit>().state as ControllerContextLoaded;

                                        context.read<MappingAndUnmappingNodesBloc>().add(
                                          DeleteMappedNodeEvent(
                                            userId: controllerContext.userId,
                                            controllerId: controllerContext.controllerId,
                                            mappedNodeEntity: node,
                                            deviceId: controllerContext.deviceId,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // Divider after each item (except possibly the last one)
                              if (index < listOfMappedNode.length - 1)
                                Divider(
                                  height: 1,
                                  thickness: 0.8,
                                  indent: 12,
                                  endIndent: 12,
                                  color: Colors.grey[400],
                                ),
                            ],
                          );
                        },
                      )
                          : Lottie.asset(
                        'assets/lottie/No_data_current.json',
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        repeat: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.105,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomMaterialButton(
                                onPressed: () {
                                  context.pop();
                                },
                                title: 'Go Back'),
                            if(!payloadSending)
                              CustomMaterialButton(
                                  onPressed: () {
                                    final selectedNodes = listOfMappedNode.where((n) => n.select).toList();
                                    if (selectedNodes.isNotEmpty) {
                                      context.read<MappingAndUnmappingNodesBloc>().add(
                                        ResendMultipleNodeDetailsMqttEvent(mappedNodeEntities: selectedNodes)
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please select at least one node')),
                                      );
                                    }
                                    setState(() {
                                      payloadSending = !payloadSending;
                                    });
                                  },
                                  title: 'Resend'
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }else{
              return const Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }

  Widget _getStatusWidget(ResendCommandEnum status) {
    switch (status) {
      case ResendCommandEnum.resendLoading:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          ),
        );
      case ResendCommandEnum.success:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 26,
          ),
        );
      case ResendCommandEnum.failure:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.error,
            color: Colors.red,
            size: 26,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showNodeDetailsBottomSheet(
      BuildContext context,
      MappedNodeEntity node,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Header
                    Text(
                      "Node Details",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    _detailTile("Node Number", node.serialNo),
                    _detailTile("QR Code", node.qrCode),
                    _detailTile("Category", node.categoryName),
                    _detailTile("Manufacture Date", node.dateManufacture),
                    _detailTile("User Name", node.userName),
                    _detailTile("Mobile Number", node.mobileNumber),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailTile(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "—",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

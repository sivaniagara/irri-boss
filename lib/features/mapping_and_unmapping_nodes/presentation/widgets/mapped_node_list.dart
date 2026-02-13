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


class MappedNodeList extends StatefulWidget {
  const MappedNodeList({
    super.key,
  });

  @override
  State<MappedNodeList> createState() => _MappedNodeListState();
}

class _MappedNodeListState extends State<MappedNodeList> {
  late List<MappedNodeEntity> listOfMappedNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final currentState = context.read<MappingAndUnmappingNodesBloc>().state as MappingAndUnmappingNodesLoaded;
    for(var i in currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity){
      print(i.select);
    }
    print("length => ${currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.length}");
    listOfMappedNode = currentState.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.map(((e){
      return e.copyWidth();
    })).toList();
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
          }
        },
      child: BlocBuilder<MappingAndUnmappingNodesBloc, MappingAndUnmappingNodesState>(
          builder: (context, state){
            if(state is MappingAndUnmappingNodesLoaded){
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
                      child: state.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.isNotEmpty
                          ? ListView.builder(
                        itemCount: state.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.length,
                        itemBuilder: (context, index) {
                          final node = state.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity[index];

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: (){
                                  _showNodeDetailsBottomSheet(context, node);
                                },
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Node: ${node.serialNo ?? "—"}',
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
                              if (index < state.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.length - 1)
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
                        'assets/lottie/no_data.json',
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomMaterialButton(
                                onPressed: () {
                                  context.pop();
                                },
                                title: 'Go Back')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }else{
              return Placeholder();
            }
          }
      ),
    );
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
            style: const TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

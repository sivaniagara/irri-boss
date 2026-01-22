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
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                minLeadingWidth: 30,
                                horizontalTitleGap: 12,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),

                                leading: Container(
                                  width: 50,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    node.serialNo ?? '—',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[900],
                                      letterSpacing: 0.4,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),

                                title: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: node.categoryName ?? '—',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal[800],
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '   •   ',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: node.qrCode ?? '—',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blueGrey[800],
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Mfg: ',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: node.dateManufacture ?? '??',
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '   •   ',
                                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                        ),
                                        TextSpan(
                                          text: node.userName ?? '—',
                                          style: TextStyle(
                                            color: Colors.indigo[700],
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (node.mobileNumber != null) ...[
                                          TextSpan(
                                            text: '   •   ',
                                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                          ),
                                          TextSpan(
                                            text: node.mobileNumber!,
                                            style: TextStyle(
                                              color: Colors.deepPurple[700],
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),

                                trailing: IconButton(
                                  onPressed: () {
                                    final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
                                    context.read<MappingAndUnmappingNodesBloc>().add(
                                      DeleteMappedNodeEvent(
                                        userId: controllerContext.userId,
                                        controllerId: controllerContext.controllerId,
                                        mappedNodeEntity: node,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.link_off_rounded, size: 22),
                                  tooltip: 'Unmap / Remove node',
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFEDF8FF),
                                    foregroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
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
}
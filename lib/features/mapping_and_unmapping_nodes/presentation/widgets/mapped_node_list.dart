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
                          itemBuilder: (context, int index) {
                            final node = state.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                spacing: 10,
                                children: [
                                  Text(node.serialNo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                  SizedBox(
                                      width: 150,
                                      child: Text(node.qrCode, style: TextStyle(fontSize: 16))
                                  ),
                                  SizedBox(
                                      width: 100,
                                      child: Text(node.categoryName, style: TextStyle(fontSize: 16), maxLines: 2,)
                                  ),
                                  IconButton(
                                      onPressed: (){
                                        final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
                                        context.read<MappingAndUnmappingNodesBloc>()
                                            .add(
                                            DeleteMappedNodeEvent(
                                                userId: controllerContext.userId,
                                                controllerId: controllerContext.controllerId,
                                                mappedNodeEntity: node
                                            )
                                        );
                                      },
                                      style: const ButtonStyle(
                                          backgroundColor:
                                          WidgetStatePropertyAll(Color(0xffEDF8FF))
                                      ),
                                      icon: Icon(Icons.link, color: Theme.of(context).primaryColor,)
                                  )
                                ],
                              ),
                            );
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white, side: const BorderSide( color: Colors.black, width: 2, ),
                              value: node.select,
                              onChanged: (value){
                                setState(() {
                                  node.select = value!;
                                });
                              },
                              title: Text(node.qrCode),
                            );
                          })
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
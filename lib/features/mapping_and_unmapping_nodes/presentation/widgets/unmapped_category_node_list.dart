import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_node_entity.dart';

import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../core/widgets/custom_outlined_button.dart';
import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../bloc/mapping_and_unmapping_nodes_bloc.dart';
import '../enums/unmapped_node_to_mapped_enum.dart';

class UnmappedCategoryNodeList extends StatefulWidget {
  final UnmappedCategoryEntity unmappedCategoryEntity;
  const UnmappedCategoryNodeList({super.key, required this.unmappedCategoryEntity});

  @override
  State<UnmappedCategoryNodeList> createState() => _UnmappedCategoryNodeListState();
}

class _UnmappedCategoryNodeListState extends State<UnmappedCategoryNodeList> {
  late UnmappedCategoryEntity unmappedCategoryEntity;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    unmappedCategoryEntity = widget.unmappedCategoryEntity.copyWith();

  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MappingAndUnmappingNodesBloc, MappingAndUnmappingNodesState>(
      listener: (context, state){
        if(state is MappingAndUnmappingNodesLoaded && state.unmappedNodeToMappedEnum == UnmappedNodeToMappedEnum.loading){
          showGradientLoadingDialog(context);
        }else if(state is MappingAndUnmappingNodesLoaded && state.unmappedNodeToMappedEnum == UnmappedNodeToMappedEnum.failure){
          context.pop();
          showErrorAlert(context: context, message: state.message);
        }else if(state is MappingAndUnmappingNodesLoaded && state.unmappedNodeToMappedEnum == UnmappedNodeToMappedEnum.success){
          context.pop();
          setState(() {
            unmappedCategoryEntity = unmappedCategoryEntity.copyWith(updateNodes: unmappedCategoryEntity.nodes.where((e) => !e.select).toList());
          });
          showSuccessAlert(
              context: context,
              message: state.unmappedNodeToMappedEnum.message,
              onPressed: (){
                final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
                context.read<MappingAndUnmappingNodesBloc>().add(
                    FetchMappingAndUnmappingEvent(
                        userId: controllerContext.userId,
                        controllerId: controllerContext.controllerId
                    )
                );
                context.pop();
                context.pop();
              }
          );
        }
      },
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  widget.unmappedCategoryEntity.categoryName,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: unmappedCategoryEntity.nodes.isNotEmpty
                    ? ListView.builder(
                    itemCount: unmappedCategoryEntity.nodes.length,
                    itemBuilder: (context, int index) {
                      final node = unmappedCategoryEntity.nodes[index];
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.105,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomOutlinedButton(
                        title: 'Cancel',
                        onPressed: () {
                          context.pop();
                        }),
                    CustomMaterialButton(
                        onPressed: () {
                          final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;

                          context.read<MappingAndUnmappingNodesBloc>().add(
                              UnMappedNodeToMappedEvent(
                                  userId: controllerContext.userId,
                                  controllerId: controllerContext.controllerId,
                                  categoryId: widget.unmappedCategoryEntity.categoryId,
                                  unmappedCategoryEntity: unmappedCategoryEntity
                              )
                          );
                          // context.push(
                          //   '${DashBoardRoutes.dashboard}${ProgramSettingsRoutes.editZone.replaceAll(':programId', program.programId.toString())}',
                          // );
                        },
                        title: 'Submit')
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

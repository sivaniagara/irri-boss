import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_list_tile.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/bloc/mapping_and_unmapping_nodes_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/widgets/mapped_node_list.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/widgets/unmapped_category_node_list.dart';

import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../domain/entities/unmapped_category_entity.dart';


class MappingAndUnmappingPage extends StatefulWidget {
  const MappingAndUnmappingPage({super.key});

  @override
  State<MappingAndUnmappingPage> createState() => _MappingAndUnmappingPageState();
}

class _MappingAndUnmappingPageState extends State<MappingAndUnmappingPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final controllerContext =
    context.read<ControllerContextCubit>().state as ControllerContextLoaded;

    context.read<MappingAndUnmappingNodesBloc>().add(
      FetchMappingAndUnmappingEvent(
        userId: controllerContext.userId,
        controllerId: controllerContext.controllerId,

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MappingAndUnmappingNodesBloc, MappingAndUnmappingNodesState>(
        listener: (context, state){},
      child: BlocBuilder<MappingAndUnmappingNodesBloc, MappingAndUnmappingNodesState>(
          builder: (context, state){
            if (state is MappingAndUnmappingNodesLoading) {
              return const Center(child: CircularProgressIndicator());
            }else if(state is MappingAndUnmappingNodesLoaded){
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    CustomListTile(
                        onTap: (){
                          showMappedNodeBottomSheet(context);
                        },
                        title: 'Mapped Nodes'
                    ),
                    for(UnmappedCategoryEntity category in state.mappingAndUnmappingNodeEntity.listOfUnmappedCategoryEntity)
                      CustomListTile(
                          onTap: (){
                            showUnmappedNodeBottomSheet(context, category);
                          },
                          title: category.categoryName
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

  void showMappedNodeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
            value: context.read<MappingAndUnmappingNodesBloc>(),
          child: MappedNodeList(),
        );
      },
    );
  }

  void showUnmappedNodeBottomSheet(BuildContext context, UnmappedCategoryEntity unmappedCategoryEntity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
            value: context.read<MappingAndUnmappingNodesBloc>(),
          child: UnmappedCategoryNodeList(unmappedCategoryEntity: unmappedCategoryEntity),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_images.dart';
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
        deviceId: controllerContext.deviceId,
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
              return Scaffold(
                appBar: CustomAppBar(title: 'Node Settings'),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(height: 10,),
                        CustomListTile(
                          image: getImages(1),
                            onTap: (){
                              showMappedNodeBottomSheet(context);
                            },
                            title: 'Mapped Nodes (${state.mappingAndUnmappingNodeEntity.listOfMappedNodeEntity.length})'
                        ),
                        for(UnmappedCategoryEntity category in state.mappingAndUnmappingNodeEntity.listOfUnmappedCategoryEntity)
                          CustomListTile(
                            image: getImages(category.categoryId),
                              onTap: (){
                                showUnmappedNodeBottomSheet(context, category);
                              },
                              title: '${category.categoryName} (${category.nodes.length})'
                          ),
                      ],
                    ),
                  ),
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

  String getImages(int categoryId){
    switch(categoryId){
      case 1 : return AppImages.mappedNodesIcon;
      case 2 : return AppImages.valveIcon;
      case 3 : return AppImages.lightIcon;
      case 4 : return AppImages.lightIcon;
      case 5 : return AppImages.moistureSensorIcon;
      case 6 : return AppImages.levelSensorIcon;
      case 7 : return AppImages.humiditySensorIcon;
      case 8 : return AppImages.temperatureSensorIcon;
      case 9 : return AppImages.flowMeterIcon;
      case 10 : return AppImages.fertilizerPumpIcon;
      case 11 : return AppImages.foggerIcon;
      case 12 : return AppImages.energyMeterIcon;
      case 13 : return AppImages.communicationNodeIcon;
      case 14 : return AppImages.pumpControlWithFlowIcon;
      case 15 : return AppImages.overHeadTankIcon;
      default : return AppImages.pumpSettingIcon;
    }
  }
}

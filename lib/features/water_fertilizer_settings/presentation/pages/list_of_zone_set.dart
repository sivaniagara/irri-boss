import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_list_tile.dart';
import 'package:niagara_smart_drip_irrigation/features/progam_zone_set/presentation/cubit/program_tab_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/progam_zone_set/presentation/enums/program_tab_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/presentation/pages/list_of_zone_in_zone_set.dart';

import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../../dashboard/utils/dashboard_routes.dart';
import '../../../irrigation_settings/utils/irrigation_settings_routes.dart';
import '../../utils/water_fertilizer_settings_routes.dart';
import '../bloc/water_fertilizer_setting_bloc.dart';

class ListOfZoneSet extends StatefulWidget {
  const ListOfZoneSet({super.key});

  @override
  State<ListOfZoneSet> createState() => _ListOfZoneSetState();
}

class _ListOfZoneSetState extends State<ListOfZoneSet> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final programTabContext = (context.read<ProgramTabCubit>().state);
    final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
    context.read<WaterFertilizerSettingBloc>().add(FetchProgramZoneSetEvent(
        userId: controllerContext.userId,
        controllerId: controllerContext.controllerId,
        subUserId: controllerContext.subUserId,
        programId: programTabContext.tab.id()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterFertilizerSettingBloc, WaterFertilizerSettingState>(
        builder: (context,state){
          print("state =ListOfZoneSet= ${state}");
          if (state is WaterFertilizerSettingLoading) {
            return const Center(child: CircularProgressIndicator());
          }else if(state is WaterFertilizerSettingLoaded){
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListView.builder(
                itemCount: state.programZoneSetEntity.listOfZoneSet.length,
                  itemBuilder: (context, index){
                  return CustomListTile(
                    iconData: Icons.keyboard_arrow_right,
                      onTap: (){
                      context.push('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.zoneSet
                          .replaceAll(':programId', state.programZoneSetEntity.programId)
                          .replaceAll(':programSettingNo', '462')
                          .replaceAll(':zoneSetId', '${index + 1}'.padLeft(3, '0'))
                      }');
                      },
                      title: 'Zone ${index == 0 ? '1' : (index * 8 + 1)} to ${(index + 1) * 8}'
                  );
                    return Text(state.programZoneSetEntity.listOfZoneSet[index].zoneSetName);
                  }
              ),
            );
          }else{
            return Placeholder();
          }
        },
    );
  }
}

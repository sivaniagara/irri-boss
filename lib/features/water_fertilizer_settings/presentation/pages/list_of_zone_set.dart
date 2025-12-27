import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_list_tile.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/presentation/pages/list_of_zone_in_zone_set.dart';

import '../../../dashboard/utils/dashboard_routes.dart';
import '../../../irrigation_settings/utils/irrigation_settings_routes.dart';
import '../../utils/water_fertilizer_settings_routes.dart';
import '../bloc/water_fertilizer_setting_bloc.dart';

class ListOfZoneSet extends StatelessWidget {
  const ListOfZoneSet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterFertilizerSettingBloc, WaterFertilizerSettingState>(
        builder: (context,state){
          print("state = $state");
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
                      context.go('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.zoneSet
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

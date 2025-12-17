import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_outlined_button.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/presentation/bloc/edit_zone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/presentation/pages/edit_zone.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/utils/controller_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/dashboard.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
// Assuming your ZoneEntity is defined in a file like this. Adjust the import path if needed.
import '../../domain/entities/program_and_zone_entity.dart';
import '../../domain/entities/zone_entity.dart';
import '../../../../../core/di/injection.dart' as di;

class ZoneList extends StatelessWidget {
  final ProgramAndZoneEntity programEntity;

  const ZoneList({
    super.key,
    required this.programEntity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Zones',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              // 3. Use the length of the dynamic list.
                itemCount: programEntity.zones.length,
                itemBuilder: (context, int index) {
                  // Get the specific zone for the current item.
                  final zone = programEntity.zones[index];
                  return ListTile(
                    onTap: () {
                    },
                    title: Text(
                      zone.zoneName,
                      style: Theme.of(context).listTileTheme.titleTextStyle,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          // TODO: Implement logic to run the zone
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        style: const ButtonStyle(
                            backgroundColor:
                            WidgetStatePropertyAll(Color(0xffEDF8FF)))),
                  );
                }),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.105,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomOutlinedButton(
                    title: 'Cancel',
                    onPressed: () {
                      context.pop();
                    }),
                CustomMaterialButton(
                    onPressed: () {
                      context.push(
                          '${DashBoardRoutes.dashboard}${ControllerSettingsRoutes.editZone.replaceAll(':programId', programEntity.programId.toString())}',
                      );
                    },
                    title: 'Add Zone')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
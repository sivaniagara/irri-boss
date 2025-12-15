import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_outlined_button.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/presentation/cubit/day_selection_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/presentation/pages/edit_zone.dart';
// Assuming your ZoneEntity is defined in a file like this. Adjust the import path if needed.
import '../../domain/entities/zone_entity.dart';
import '../../../../../core/di/injection.dart' as di;

class ZoneList extends StatelessWidget {
  final List<ZoneEntity> zones;

  const ZoneList({
    super.key,
    required this.zones,
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
                itemCount: zones.length,
                itemBuilder: (context, int index) {
                  // Get the specific zone for the current item.
                  final zone = zones[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => di.sl<DaySelectionCubit>(),
                                // Pass the selected zone to the EditZone screen
                                child: EditZone(),
                              )));
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
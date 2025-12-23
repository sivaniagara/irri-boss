import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_outlined_button.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/presentation/bloc/edit_zone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/presentation/pages/edit_zone_page.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/presentation/bloc/program_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/utils/controller_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/dashboard.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
// Assuming your ZoneEntity is defined in a file like this. Adjust the import path if needed.
import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../domain/entities/program_and_zone_entity.dart';
import '../../domain/entities/zone_entity.dart';
import '../../../../core/di/injection.dart' as di;
import '../../utils/program_settings_routes.dart';
import '../pages/controller_program.dart';

class ZoneList extends StatelessWidget {
  final int programId;

  const ZoneList({
    super.key,
    required this.programId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProgramBloc, ProgramState>(
        listener: (context, state){
          if(state is ProgramLoaded && state.zoneDeleteStatus == ZoneDeleteStatus.loading){
            showGradientLoadingDialog(context);
          }else if(state is ProgramLoaded && state.zoneDeleteStatus == ZoneDeleteStatus.failure){
            context.pop();
            showErrorAlert(context: context, message: state.zoneDeleteStatus.message);
          }else if(state is ProgramLoaded && state.zoneDeleteStatus == ZoneDeleteStatus.success){
            context.pop();
            final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
            context.read<ProgramBloc>().add(FetchPrograms(userId: controllerContext.userId, controllerId: controllerContext.controllerId));
            showSuccessAlert(
                context: context,
                message: state.zoneDeleteStatus.message,
                onPressed: (){
                  context.pop();
                }
            );
          }
        },
      child: BlocBuilder<ProgramBloc, ProgramState>(
        builder: (context, state) {
          if (state is! ProgramLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final program = state.programs
              .firstWhere((p) => p.programId == programId);

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
                  child: program.zones.isNotEmpty
                      ? ListView.builder(
                      itemCount: program.zones.length,
                      itemBuilder: (context, int index) {
                        // Get the specific zone for the current item.
                        final zone = program.zones[index];
                        return ListTile(
                          onTap: () {
                            context.push(
                              '${DashBoardRoutes.dashboard}${ProgramSettingsRoutes.editZone
                                  .replaceAll(':programId', program.programId.toString())
                                  .replaceAll(':zoneSerialNo', zone.zoneName.split('ZONE')[1])
                              }',
                            );
                          },
                          title: Text(
                            zone.zoneName,
                            style: Theme.of(context).listTileTheme.titleTextStyle,
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
                                context.read<ProgramBloc>()
                                    .add(
                                    DeleteZone(
                                        userId: controllerContext.userId,
                                        controllerId: controllerContext.controllerId,
                                        programId: program.programId.toString(),
                                        zoneSerialNo: zone.zoneName.split('ZONE')[1]
                                    )
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              style: const ButtonStyle(
                                  backgroundColor:
                                  WidgetStatePropertyAll(Color(0xffEDF8FF)))),
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
                              '${DashBoardRoutes.dashboard}${ProgramSettingsRoutes.editZone.replaceAll(':programId', program.programId.toString())}',
                            );
                          },
                          title: 'Add Zone')
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

  }
}
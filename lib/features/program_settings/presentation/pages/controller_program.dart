import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_list_tile.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/domain/entities/zone_entity.dart';
import '../../../../routes.dart';
import '../../../dashboard/utils/dashboard_routes.dart';
import '../../domain/entities/program_and_zone_entity.dart';
import '../../utils/program_settings_routes.dart';
import '../bloc/program_bloc.dart';
import '../../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../widgets/zone_list.dart';


enum ZoneDeleteStatus{initial, loading, success, failure}

extension ZoneDeleteStatusExtension on ZoneDeleteStatus {
  String get message {
    switch (this) {
      case ZoneDeleteStatus.initial:
        return '';
      case ZoneDeleteStatus.loading:
        return 'Deleting zone...';
      case ZoneDeleteStatus.success:
        return 'Zone deleted successfully';
      case ZoneDeleteStatus.failure:
        return 'Failed to delete zone';
    }
  }
}


class ControllerProgram extends StatefulWidget {
  const ControllerProgram({super.key});

  @override
  State<ControllerProgram> createState() => _ControllerProgramState();
}

class _ControllerProgramState extends State<ControllerProgram> {

  @override
  void initState() {
    super.initState();

    final controllerContext =
    context.read<ControllerContextCubit>().state as ControllerContextLoaded;

    context.read<ProgramBloc>().add(
      FetchPrograms(
        userId: controllerContext.userId,
        controllerId: controllerContext.controllerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBloc, ProgramState>(
      builder: (context, state) {
        if (state is ProgramLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProgramLoaded) {
          return Column(
            children: [
              ...List.generate(state.programs.length, (index){
                final program = state.programs[index];
                return CustomListTile(
                    onTap: () {
                      showZoneBottomSheet(context, program.programId);
                    },
                    title: program.programName
                );
              }),
              Card(
                color: Theme.of(context).primaryColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.push(
                      '${DashBoardRoutes.dashboard}${ProgramSettingsRoutes.commonIdSettings}',
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.settings,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Common ID Settings",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        }

        if (state is ProgramError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }

  void showZoneBottomSheet(BuildContext context, int programId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ZoneList(programId: programId);
      },
    );
  }

}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/domain/entities/zone_entity.dart';
import '../../../../../routes.dart';
import '../../domain/entities/program_and_zone_entity.dart';
import '../bloc/program_bloc.dart';
import '../cubit/controller_context_cubit.dart';
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
          return ListView.builder(
            itemCount: state.programs.length,
            itemBuilder: (context, index) {
              final program = state.programs[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    showZoneBottomSheet(context, program.programId);
                  },
                  title: Text(
                    program.programName,
                    style: Theme.of(context)
                        .listTileTheme
                        .titleTextStyle,
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 32,
                  ),
                ),
              );
            },
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


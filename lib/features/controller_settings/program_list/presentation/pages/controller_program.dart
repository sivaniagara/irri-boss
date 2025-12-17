import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/domain/entities/zone_entity.dart';
import '../../../../../routes.dart';
import '../../domain/entities/program_and_zone_entity.dart';
import '../bloc/program_bloc.dart';
import '../widgets/zone_list.dart';


class ControllerProgram extends StatelessWidget {
  const ControllerProgram({super.key});

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
                    showZoneBottomSheet(context, program);
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

  void showZoneBottomSheet(BuildContext context, ProgramAndZoneEntity programEntity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ZoneList(programEntity: programEntity,),
    );
  }
}


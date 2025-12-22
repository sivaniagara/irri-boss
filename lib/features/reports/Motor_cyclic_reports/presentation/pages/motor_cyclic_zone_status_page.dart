import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/motor_cyclic_entities.dart';
import '../bloc/motor_cyclic_mode.dart';
import '../widgets/zone_status_card.dart';

class MotorCyclicZoneStatusView extends StatelessWidget {
  final MotoCyclicEntity data;

  const MotorCyclicZoneStatusView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotorCyclicViewCubit, MotorCyclicViewState>(
      builder: (context, viewState) {
        final selectedProgramIndex =
            viewState.selectedProgramIndex;

        final program = data.data[selectedProgramIndex];

        return Column(
          children: [
            // 🔹 PROGRAM DROPDOWN
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<int>(
                value: selectedProgramIndex,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.settings),
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  data.data.length,
                      (index) => DropdownMenuItem(
                    value: index,
                    child: Text(
                      "Program ${data.data[index].program}",
                    ),
                  ),
                ),
                onChanged: (value) {
                  context
                      .read<MotorCyclicViewCubit>()
                      .selectProgram(value!);
                },
              ),
            ),

            // 🔹 ZONE GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: program.zoneList.length,
                itemBuilder: (context, index) {
                  return ZoneStatusCard(
                    program.zoneList[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

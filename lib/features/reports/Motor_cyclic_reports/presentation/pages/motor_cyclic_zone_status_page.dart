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
        final selectedProgramIndex = viewState.selectedProgramIndex;

        // 🔹 Convert dropdown index → program number (1–6)
        final selectedProgramNo =
        (selectedProgramIndex + 1).toString();

        // 🔹 Get ALL records of selected program
        final allZones = data.data
            .where((e) => e.program == selectedProgramNo)
            .expand((e) => e.zoneList)
            .toList();

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
                  6,
                      (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text('Program ${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<MotorCyclicViewCubit>()
                        .selectProgram(value);
                  }
                },
              ),
            ),
             // 🔹 ZONE GRID
            Expanded(
              child: allZones.isEmpty
                  ?  Center(
                child: Image.asset("assets/images/common/nodata.png",width: 60,height: 60,),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: allZones.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ZoneStatusCard(allZones[index]),
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

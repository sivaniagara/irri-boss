import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/power_entities.dart';

class PowerDetailsCard extends StatelessWidget {
  final PowerDatumEntity data;
  final int modelId ;
  const PowerDetailsCard({super.key, required this.data, required this.modelId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              RowItem("Total Power ON", data.totalPowerOnTime, Colors.green, unitIcons: Icons.electric_bolt,),
              RowItem("Power OFF Time", data.totalPowerOffTime, Colors.red,unitIcons: Icons.offline_bolt,),
              RowItem("Motor Run Time", data.motorRunTime, Colors.cyan,unitIcons: Icons.water_outlined,),
              RowItem("Motor Idle Time", data.motorIdleTime, Colors.red,unitIcons: Icons.heat_pump_outlined,),
              RowItem("Dry Run Time", data.dryRunTripTime, Colors.red,unitIcons: Icons.dry,),
              RowItem("Cyclic Trip Time", data.cyclicTripTime, Colors.red,unitIcons: Icons.cyclone,),
              RowItem("Other Trip Time", data.otherTripTime, Colors.red,unitIcons: Icons.access_time,),
              if(modelId == 27)
                RowItem("Motor2 Run Time", data.motorRunTime2, Colors.cyan,unitIcons: Icons.water_outlined,),
              if(modelId == 27)
                RowItem("Motor2 Idle Time", data.motorIdleTime2, Colors.red,unitIcons: Icons.heat_pump_outlined,),
              if(modelId == 27)
                RowItem("Motor2 DryRun Time", data.dryRunTripTime2, Colors.red,unitIcons: Icons.dry,),
              if(modelId == 27)
                RowItem("Motor2 CyclicTrip Time", data.cyclicTripTime2, Colors.red,unitIcons: Icons.cyclone,),
              if(modelId == 27)
                RowItem("Motor2 OtherTrip Time", data.otherTripTime2, Colors.red,unitIcons: Icons.access_time,),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              RowItem("Total Flow", data.totalFlowToday, Colors.red, unit: "Liters",unitIcons: Icons.water,),
              RowItem("Cumulative Flow", data.cumulativeFlowToday, Colors.red, unit: "Liters",unitIcons: Icons.water,),
              RowItem("Average Flow Rate", data.averageFlowRate, Colors.red, unit: "L/s",unitIcons: Icons.water,),
              RowItem("Pressure In", data.pressureIn, Colors.red, unit: "Bar",unitIcons: Icons.compress_rounded,),
              RowItem("Pressure Out", data.pressureOut, Colors.red, unit: "Bar",unitIcons: Icons.compress,),
            ],
          ),
        ),
      ],
    );
  }
}

class RowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String unit;
  final IconData unitIcons;

  const RowItem(
      this.label,
      this.value,
      this.color, {
        super.key,
        this.unit = "Hours", required this.unitIcons,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(unitIcons,color: color,),
          SizedBox(width: 5,),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black)),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text(unit),
        ],
      ),
    );
  }
}


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
              RowItem("Total Power ON", data.totalPowerOnTime, Colors.green, unitIcons: "assets/images/report_menu/power_on_time.png",),
              RowItem("Power OFF Time", data.totalPowerOffTime, Colors.red,unitIcons: "assets/images/report_menu/power_off_time.png",),
              RowItem("Motor Run Time", data.motorRunTime, Colors.cyan,unitIcons: "assets/images/report_menu/motor_run_time.png",),
              RowItem("Motor Idle Time", data.motorIdleTime, Colors.red,unitIcons: "assets/images/report_menu/motor_ideal_time.png",),
              RowItem("Dry Run Time", data.dryRunTripTime, Colors.red,unitIcons: "assets/images/report_menu/dry_run_time.png",),
              RowItem("Cyclic Trip Time", data.cyclicTripTime, Colors.red,unitIcons: "assets/images/report_menu/cyclic_trip_time.png",),
              RowItem("Other Trip Time", data.otherTripTime, Colors.red,unitIcons:"assets/images/report_menu/other_trip_time.png",),
              if(modelId == 27)
                RowItem("Motor2 Run Time", data.motorRunTime2, Colors.cyan,unitIcons:"assets/images/report_menu/motor_run_time.png",),
              if(modelId == 27)
                RowItem("Motor2 Idle Time", data.motorIdleTime2, Colors.red,unitIcons: "assets/images/report_menu/motor_ideal_time.png",),
              if(modelId == 27)
                RowItem("Motor2 DryRun Time", data.dryRunTripTime2, Colors.red,unitIcons: "assets/images/report_menu/dry_run_time.png",),
              if(modelId == 27)
                RowItem("Motor2 CyclicTrip Time", data.cyclicTripTime2, Colors.red,unitIcons: "assets/images/report_menu/cyclic_trip_time.png",),
              if(modelId == 27)
                RowItem("Motor2 OtherTrip Time", data.otherTripTime2, Colors.red,unitIcons: "assets/images/report_menu/other_trip_time.png",),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              RowItem("Total Flow", data.totalFlowToday, Colors.red, unit: "Liters",unitIcons: "assets/images/report_menu/other_trip_time.png",),
              RowItem("Cumulative Flow", data.cumulativeFlowToday, Colors.red, unit: "Liters",unitIcons: "assets/images/report_menu/avarage_flow_rate.png",),
              RowItem("Average Flow Rate", data.averageFlowRate, Colors.red, unit: "L/s",unitIcons: "assets/images/report_menu/avarage_flow_rate.png",),
              RowItem("Pressure In", data.pressureIn, Colors.red, unit: "Bar",unitIcons: "assets/images/report_menu/pressure_in.png",),
              RowItem("Pressure Out", data.pressureOut, Colors.red, unit: "Bar",unitIcons:"assets/images/report_menu/pressure_out.png",),
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
  final String unitIcons;

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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black, // or any color you want
            width: 0.5,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(8),
         child: Row(
          children: [
            Image.asset(
              unitIcons,
              width: 20,
              height: 20,
             ),
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
      ),
    );
  }
}


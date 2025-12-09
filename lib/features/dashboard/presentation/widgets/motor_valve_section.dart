import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MotorValveSection extends StatelessWidget {
  final String motorOn;
  final String motorOn2;
  final String valveOn;
  final int model;

  const MotorValveSection({super.key, required this.motorOn, required this.valveOn, required this.model, required this.motorOn2});

  @override
  Widget build(BuildContext dialogContext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 🔹 Motor image
        Image.asset(
          motorOn == "0"
              ? 'assets/images/common/ui_motor.gif' // motor ON
              : motorOn == "1"
              ? 'assets/images/common/live_motor_off.png' // motor OFF
              : 'assets/images/common/ui_motor_yellow.png', // no status
          width: 60,
          height: 60,
        ),

        // 🔹 ON / OFF buttons now in a row
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                AnimatedSwitcher(duration: const Duration(milliseconds: 400));
                HapticFeedback.mediumImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                side: const BorderSide(color: Colors.grey, width: 4),
                elevation: 5,
              ),
              child: const Text("ON"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                AnimatedSwitcher(duration: const Duration(milliseconds: 400));
                HapticFeedback.mediumImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                side: const BorderSide(color: Colors.grey, width: 4),
                 elevation: 5,
              ),
               child: const Text("OFF"),
            ),
          ],
        ),

        // 🔹 Valve image
       ( model == 1 || model == 5) ?
        Image.asset(
          valveOn == "0"
              ? 'assets/images/common/valve_open.gif' // valve open
              : valveOn == "1"
              ? 'assets/images/common/valve_stop.png' // valve stop
              : 'assets/images/common/valve_no_communication.png', // no communication
          width: 60,
          height: 60,
        ) :  ( model == 27) ?       Image.asset(
         motorOn2 == "0"
             ? 'assets/images/common/ui_motor.gif' // motor ON
             : motorOn2 == "1"
             ? 'assets/images/common/live_motor_off.png' // motor OFF
             : 'assets/images/common/ui_motor_yellow.png', // no status
         width: 60,
         height: 60,
       ) : Container(),
      ],
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';

import '../cubit/dashboard_cubit.dart';

class MotorValveSection extends StatelessWidget {
  final String motorOn;
  final String motorOn2;
  final String valveOn;
  final int model;
  final Map<String, dynamic> userData;

  const MotorValveSection({super.key, required this.motorOn, required this.valveOn, required this.model, required this.motorOn2, required this.userData});

  @override
  Widget build(BuildContext dialogContext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 🔹 Motor image
        Image.asset(
          motorOn == "1"
              ? 'assets/images/common/ui_motor.gif' // motor ON
              : motorOn == "0"
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
                   HapticFeedback.mediumImpact();

                  dialogContext.read<DashboardCubit>().motorOnOff(
                    userId: userData['userId'],
                    subUserId: userData['subUserId'],
                    controllerId: userData['controllerId'],
                    isOn: true,
                    dualPump: model == 27,
                    deviceId: userData['deviceId'],
                  );

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
                dialogContext.read<DashboardCubit>().motorOnOff(
                  userId: userData['userId'],
                  subUserId: userData['subUserId'],
                  controllerId: userData['controllerId'],
                  isOn: false,
                  dualPump: model == 27,
                  deviceId: userData['deviceId'],
                );
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
        GestureDetector(
          onTap: () {
            dialogContext.push(DashBoardRoutes.nodeStatus, extra: userData);
          },
          child: Image.asset(
            valveOn == "1"
                ? 'assets/images/common/valve_open.gif' // valve open
                : valveOn == "0"
                ? 'assets/images/common/valve_stop.png' // valve stop
                : 'assets/images/common/valve_no_communication.png', // no communication
            width: 60,
            height: 60,
          ),
        ) :  ( model == 27) ? Image.asset(
         motorOn2 == "1"
             ? 'assets/images/common/ui_motor.gif' // motor ON
             : motorOn2 == "0"
             ? 'assets/images/common/live_motor_off.png' // motor OFF
             : 'assets/images/common/ui_motor_yellow.png', // no status
         width: 60,
         height: 60,
       ) : Container(),
      ],
    );
  }
}



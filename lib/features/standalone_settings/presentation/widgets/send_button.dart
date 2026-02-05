import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/standalone_bloc.dart';
import '../bloc/standalone_event.dart';

class SendButton extends StatelessWidget {
  final String userId;
  final String subUserId;
  final String controllerId;
  final String deviceId;
  final String menuId;
  final String settingsId;
  final String successMessage;
  final StandaloneSendType sendType;

  const SendButton({
    super.key,
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.deviceId,
    required this.menuId,
    required this.settingsId,
    required this.sendType,
    this.successMessage = "message delivered",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<StandaloneBloc>().add(
            SendStandaloneConfigEvent(
              userId: userId,
              subUserId: subUserId,
              controllerId: controllerId,
              deviceId: deviceId,
              menuId: menuId,
              settingsId: settingsId,
              successMessage: successMessage,
              sendType: sendType,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0288D1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text("SEND", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

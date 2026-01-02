import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/standalone_bloc.dart';

class SendButton extends StatelessWidget {
  final String userId;
  final String controllerId;
  final String menuId;
  final String settingsId;
  final String successMessage;

  const SendButton({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.menuId,
    required this.settingsId,
    this.successMessage = "Data sented successfully",
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
              controllerId: controllerId,
              menuId: menuId,
              settingsId: settingsId,
              successMessage: successMessage,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/standalone_bloc.dart';


class SendButton extends StatelessWidget {
  final String userId;
  final String controllerId;

  const SendButton({
    super.key,
    required this.userId,
    required this.controllerId,
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
              controllerId: controllerId, successMessage: '',
            ),
          );
        },
        child: const Text("SEND"),
      ),
    );
  }
}

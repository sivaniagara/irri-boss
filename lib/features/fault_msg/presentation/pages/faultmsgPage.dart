import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/fault_msg/presentation/widgets/faultmsg_bubble.dart';
import '../../data/models/faultmsg_model.dart';
import '../bloc/faultmsg_bloc.dart';
import '../bloc/faultmsg_bloc_event.dart';
import '../bloc/faultmsg_bloc_state.dart';

class faultmsgPage extends StatelessWidget {
  const faultmsgPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAULT MESSAGE")),
      body: BlocBuilder<faultmsgBloc, faultmsgState>(
        builder: (context, state) {
           if (state is faultmsgLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is faultmsgLoaded) {
             return ListView.builder(
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final m = state.messages[index];
                return faultmsgBubble(
                  msg: FaultDatum(userId: m.userId, controllerId: m.controllerId, messageCode: m.messageCode, controllerMessage: m.controllerMessage, readStatus: m.readStatus, messageType: m.messageType, messageDescription: m.messageDescription, ctrlDate: m.ctrlDate, ctrlTime: m.ctrlTime),
                );
              },
            );
          }

          if (state is faultmsgError) {
            return Center(child: Text(state.message,style: TextStyle(color: Colors.black),));
          }

           return const SizedBox();
        },
      ),
    );
  }
}

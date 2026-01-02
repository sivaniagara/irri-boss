import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import '../../../../core/utils/common_date_picker.dart';
import '../../data/models/sendrev_model.dart';
import '../../domain/usecases/sendrevmsgParams.dart';
import '../bloc/sendrev_bloc.dart';
import '../bloc/sendrev_bloc_event.dart';
import '../bloc/sendrev_bloc_state.dart';
import '../widgets/chat_bubble.dart';

class SendRevPage extends StatelessWidget {

   final Map<String, dynamic> params;

  const SendRevPage({
    super.key,
    required this.params,
  });



  @override
  Widget build(BuildContext context) {


    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(title: const Text("Send and Receive"),
            actions: [
              Row(
                children: [
                  // Text('${params['fromDate']}', style: const TextStyle(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today,),
                    onPressed: () async {
                      final result = await pickReportDate(
                        context: context,
                        allowRange: false,
                      );
      
                      if (result == null) return;
      
                      context.read<SendrevBloc>().add(
                        LoadMessagesEvent(
                            userId: params["userId"],
                            subuserId: params["subuserId"] ?? 0,
                            controllerId: params["controllerId"],
                            fromDate: result.fromDate,
                            toDate: result.toDate,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],),
        body: BlocBuilder<SendrevBloc, SendrevState>(
          builder: (context, state) {
            if (state is SendrevLoading) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (state is SendrevLoaded) {
              return ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final m = state.messages[index];
                  return ChatBubble(
                    msg: SendrevDatum(
                      date: m.date, msgType: m.msgType, ctrlMsg: m.ctrlMsg, ctrlDesc: m.ctrlMsg, status: m.status, msgCode: "", time: m.time,
                    ),
                  );
                },
              );
            }
             if (state is SendrevError) {
              return Center(child: Text(state.message,style: TextStyle(color: Colors.black),));
            }
      
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/common_date_picker.dart';
import '../../data/models/sendrev_model.dart';
import '../bloc/sendrev_bloc.dart';
import '../bloc/sendrev_bloc_event.dart';
import '../bloc/sendrev_bloc_state.dart';
import '../widgets/chat_bubble.dart';

class SendRevPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const SendRevPage({
    super.key,
    required this.params,
  });

  @override
  State<SendRevPage> createState() => _SendRevPageState();
}

class _SendRevPageState extends State<SendRevPage> {
  bool showColonMessagesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final userId = int.tryParse(widget.params["userId"].toString()) ?? 0;
    final subuserId = int.tryParse(widget.params["subuserId"]?.toString() ?? "0") ?? 0;
    final controllerId = int.tryParse(widget.params["controllerId"].toString()) ?? 0;

    context.read<SendrevBloc>().add(
      LoadMessagesEvent(
        userId: userId,
        subuserId: subuserId,
        controllerId: controllerId,
        fromDate: today,
        toDate: today,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text(
          "Send and Receive",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                color: Colors.black,
                onPressed: () async {
                  final result = await pickReportDate(
                    context: context,
                    allowRange: false,
                  );

                  if (result == null) return;

                  final userId = int.tryParse(widget.params["userId"].toString()) ?? 0;
                  final subuserId = int.tryParse(widget.params["subuserId"]?.toString() ?? "0") ?? 0;
                  final controllerId = int.tryParse(widget.params["controllerId"].toString()) ?? 0;

                  context.read<SendrevBloc>().add(
                    LoadMessagesEvent(
                      userId: userId,
                      subuserId: subuserId,
                      controllerId: controllerId,
                      fromDate: result.fromDate,
                      toDate: result.toDate,
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  showColonMessagesOnly ? Icons.chat : Icons.message,
                ),
                color: Colors.black,
                onPressed: () {
                  setState(() {
                    showColonMessagesOnly = !showColonMessagesOnly;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<SendrevBloc, SendrevState>(
        builder: (context, state) {
          if (state is SendrevInitial || state is SendrevLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          if (state is SendrevLoaded) {
            final filteredMessages = state.messages.where((m) {
              final text = m.ctrlMsg ?? "";
              final bool isSpecialMessage = text.length > 4 &&
                  text[3] == ':' &&
                  ':'.allMatches(text).length > 4;

              return showColonMessagesOnly
                  ? isSpecialMessage
                  : !isSpecialMessage;
            }).toList();

            if (filteredMessages.isEmpty) {
              return const Center(
                child: Text(
                  "No messages found",
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredMessages.length,
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              itemBuilder: (context, index) {
                final m = filteredMessages[index];

                return ChatBubble(
                  msg: SendrevDatum(
                    date: m.date,
                    msgType: m.msgType,
                    ctrlMsg: m.ctrlMsg,
                    ctrlDesc: m.ctrlMsg,
                    status: m.status,
                    msgCode: "",
                    time: m.time,
                  ),
                );
              },
            );
          }

          if (state is SendrevError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

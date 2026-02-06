import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/common_date_picker.dart';
import '../../data/models/sendrev_model.dart';
import '../bloc/sendrev_bloc.dart';
import '../bloc/sendrev_bloc_event.dart';
import '../bloc/sendrev_bloc_state.dart';
import '../widgets/chat_bubble.dart';
import '../../../../core/di/injection.dart' as di;

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
  final ScrollController _scrollController = ScrollController();
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      _shouldAutoScroll = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _shouldAutoScroll) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _parseInt(widget.params["userId"]);
    final subuserId = _parseInt(widget.params["subuserId"]);
    final controllerId = _parseInt(widget.params["controllerId"]);
    final fromDate = widget.params["fromDate"] ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final toDate = widget.params["toDate"] ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      create: (context) => di.sl<SendrevBloc>()
        ..add(LoadMessagesEvent(
          userId: userId,
          subuserId: subuserId,
          controllerId: controllerId,
          fromDate: fromDate,
          toDate: toDate,
        ))
        ..add(StartPollingEvent(
          userId: userId,
          subuserId: subuserId,
          controllerId: controllerId,
          fromDate: fromDate,
          toDate: toDate,
        )),
      child: Builder(builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9), // Light green background matching irrigation theme
            image: const DecorationImage(
              image: AssetImage('assets/images/common/mountain.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.08,
              scale: 1.5,
            ),
          ),
          child: BlocConsumer<SendrevBloc, SendrevState>(
            listener: (context, state) {
              if (state is SendrevLoaded) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
              }
            },
            builder: (context, state) {
              if (state is SendrevLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SendrevLoaded) {
                if (state.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages to display.',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.messages.length + 1,
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return const SizedBox(height: 100);
                    }
                    final m = state.messages[index];
                    return ChatBubble(
                      msg: SendrevDatum(
                        date: m.date,
                        time: m.time,
                        msgType: m.msgType,
                        ctrlMsg: m.ctrlMsg,
                        ctrlDesc: m.ctrlDesc,
                        status: m.status,
                        msgCode: m.msgCode,
                      ),
                    );
                  },
                );
              }
              if (state is SendrevError) {
                return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.red)));
              }

              return const SizedBox();
            },
          ),
        );
      }),
    );
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

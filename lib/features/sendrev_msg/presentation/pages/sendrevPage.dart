import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/sendrev_bloc.dart';
import '../bloc/sendrev_bloc_event.dart';
import '../bloc/sendrev_bloc_state.dart';
import '../widgets/chat_bubble.dart';
import '../../../../core/di/injection.dart' as di;
import '../../data/models/sendrev_model.dart';

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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    final userId = _parseInt(widget.params["userId"]);
    final subuserId = _parseInt(widget.params["subuserId"]);
    final controllerId = _parseInt(widget.params["controllerId"]);
    final fromDate = widget.params["fromDate"] ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final toDate = widget.params["toDate"] ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    final bloc = context.read<SendrevBloc>();
    
    bloc.add(LoadMessagesEvent(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    ));
    bloc.add(StartPollingEvent(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    ));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Only auto-scroll if we are within 100 pixels of the bottom
      _shouldAutoScroll = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
            // Filter out live messages (LD codes)
            final filteredMessages = state.messages.where((m) => !m.msgCode.startsWith('LD')).toList();

            return RefreshIndicator(
              onRefresh: () async {
                _refreshData();
              },
              child: filteredMessages.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: const Text(
                          'No messages to display.',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredMessages.length + 1,
                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                      itemBuilder: (context, index) {
                        if (index == filteredMessages.length) {
                          return const SizedBox(height: 100);
                        }
                        final m = filteredMessages[index];
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
                    ),
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
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

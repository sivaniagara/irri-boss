import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/sendrev_model.dart';

class ChatBubble extends StatelessWidget {
  final SendrevDatum msg;

  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.msgType == "SENT" ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: msg.msgType == "SENT" ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          msg.msgType == "SENT" ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            /// Message text
            Text(
              msg.ctrlMsg,
              style: TextStyle(
                color: msg.msgType == "SENT" ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 5),

            /// Time + tick
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: msg.msgType == "SENT" ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),

                /// ✔ Show tick only for SENT messages
                if (msg.status == "1")
                  msg.msgType == "SENT" ? Row(
                    children: [
                      const SizedBox(width: 4),
                      Icon(
                        msg.status == "1" ? Icons.done_all : Icons.done,
                        size: 16,
                        color: msg.status == "1" ? Colors.white : Colors.white70,
                      ),
                    ],
                  ) : SizedBox()
              ],
            )
          ],
        ),
      ),
    );
  }
}
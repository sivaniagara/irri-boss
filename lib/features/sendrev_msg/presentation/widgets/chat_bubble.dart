import 'package:flutter/material.dart';
import '../../data/models/sendrev_model.dart';

class ChatBubble extends StatelessWidget {
  final SendrevDatum msg;

  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final isSent = msg.msgType == "SENT";
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Align(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSent ? const Color(0xFF1E88E5) : Colors.white,
            // Premium chat tail design
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isSent ? 20 : 4),
              bottomRight: Radius.circular(isSent ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Date and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    msg.date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isSent ? Colors.white.withOpacity(0.9) : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    msg.time,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isSent ? Colors.white.withOpacity(0.8) : Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Main Message
              Text(
                msg.ctrlMsg,
                style: TextStyle(
                  color: isSent ? Colors.white : Colors.black87,
                  fontSize: 15, // Increased size for better visibility
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (msg.ctrlDesc.isNotEmpty && msg.ctrlDesc != msg.ctrlMsg) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Divider(color: Colors.white24, thickness: 0.5),
                ),
                Text(
                  msg.ctrlDesc,
                  style: TextStyle(
                    color: isSent ? Colors.white.withOpacity(0.95) : Colors.black87,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

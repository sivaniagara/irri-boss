import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/faultmsg_model.dart';

class faultmsgBubble extends StatelessWidget {
  final FaultDatum msg;

  const faultmsgBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER - messageDescription
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  msg.messageDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// DATE + TIME
          Text(
            "${msg.ctrlDate}  •  ${msg.ctrlTime}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),

          const Divider(height: 20),

          /// BODY - controllerMessage
          Text(
            msg.controllerMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          /// READ STATUS
          if (msg.readStatus == "1")
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.done_all, size: 16, color: Colors.grey),
                SizedBox(width: 4),

              ],
            ),
        ],
      ),
    );
  }
}

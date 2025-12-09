

import 'package:flutter/material.dart';

class MsgDescSection extends StatelessWidget {
  final String msg;
  const MsgDescSection({
    super.key,
    required this.msg,
  });

  @override
  Widget build(BuildContext dialogContext) {
    return  Center(child: Text(msg.isEmpty ? "No Message" : msg, textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white,)));
  }
}

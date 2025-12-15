// import 'package:flutter/material.dart';
//
// class ChatBubble extends StatelessWidget {
//   final SendRevMsg msg;
//
//   const ChatBubble({super.key, required this.msg});
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: msg.isSender ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//         decoration: BoxDecoration(
//           color: msg.isSender ? Colors.blue : Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(
//           msg.message,
//           style: TextStyle(
//             color: msg.isSender ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

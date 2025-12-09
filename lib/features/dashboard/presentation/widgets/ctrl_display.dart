import 'package:flutter/material.dart';

class CtrlDisplay extends StatelessWidget {
  final String signal;
  final String battery;
  final String l1display;
  final String l2display;

  const CtrlDisplay({
    super.key,
    required this.signal,
    required this.battery,
    required this.l1display,
    required this.l2display,
  });

  @override
  Widget build(BuildContext dialogContext) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: Color(0xFFC1F629),
        borderRadius: BorderRadius.circular(8),
        // border: Border.all()
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                const Icon(Icons.signal_cellular_alt,color: Color(0xFFC1F629)),
                Text("$signal%",style: TextStyle(color: Color(0xFFC1F629),fontWeight: FontWeight.bold),),
              ]),
               Column(children: [
              Text(l1display, style: const TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFC1F629))),
              Text(l2display,style: TextStyle(color: Color(0xFFC1F629),fontWeight: FontWeight.bold),),
              ]),
              Column(children: [
                const Icon(Icons.battery_full, color: Color(0xFFC1F629),),
                Text("$battery.V",style: TextStyle(color: Color(0xFFC1F629),fontWeight: FontWeight.bold),),
              ]),
            ],
          ),

        ],
      ),
    );
  }
}

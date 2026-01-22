import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'fert_live_model.dart';

class FertilizerTank extends StatelessWidget {
  final FertilizerStatus fert;
  final bool motorOn;

  const FertilizerTank({
    super.key,
    required this.fert,
    required this.motorOn,
  });

  @override
  Widget build(BuildContext context) {
    final animate = motorOn && fert.isOn && fert.rate > 0;

    return Column(
      children: [
        Text('F${fert.index}'),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
            gradient: animate
                ? LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade100,
              ],
            )
                : null,
          ),
          child: animate
              ? const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 16,
              ),
            ),
          )
              : null,
        ),
        const SizedBox(height: 4),
        Text('${fert.rate}'),
      ],
    );
  }
}


bool shouldAnimateFlow({
  required bool motorOn,
  required FertilizerStatus fert,
}) {
  return motorOn && fert.isOn && fert.rate > 0;
}

Widget buildFertilizers(LiveFertilizerState state) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: state.fertilizers
        .map((f) => FertilizerTank(
      fert: f,
      motorOn: state.motorOn,
    ))
        .toList(),
  );
}

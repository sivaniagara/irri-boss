import 'package:flutter/material.dart';
import '../../domain/entities/tdy_valve_status_entities.dart';

class ZoneStatusCardTdyValveStatus extends StatelessWidget {
  final TdyValveStatusEntity zone;

  const ZoneStatusCardTdyValveStatus(this.zone, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: zone.data.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: tdyZoneStatusCard(zone.data[index]),
        );
      },
    );
  }

  Widget tdyZoneStatusCard(TdyValveStatusDatumEntity data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // 🔹 TOP TITLE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              data.duration ?? "00:00",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 Image.asset(
                  "assets/images/common/valve.png",
                  width: 50,
                  height: 50,
                ),
                Text(
                  "${data.zone} ",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 DURATION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Text(
              "${data.litres} Lts",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

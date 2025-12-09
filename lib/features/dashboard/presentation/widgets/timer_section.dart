import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';

class TimerSection extends StatelessWidget {
  final String setTime;
  final String remainingTime;

  const TimerSection({
    super.key,
    required this.setTime,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext dialogContext) {
    return Row(
      children: const [
        Expanded(
          child: TimerCard(title: "Run Time", time: "00:00:00"),
        ),
        SizedBox(width: 10), // spacing between cards
        Expanded(
          child: TimerCard(title: "Remaining Time", time: "00:00:00"),
        ),
      ],
    );
  }
}

class TimerCard extends StatelessWidget {
  final String title;
  final String time;

  const TimerCard({required this.title, required this.time});

  @override
  Widget build(BuildContext dialogContext) {
    return GlassCard(
      padding: const EdgeInsets.all(1),
      margin: const EdgeInsets.all(1),
      child: Container(
        height: 100, // Only height is fixed, width fills automatically
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title with bottom border
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Time row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

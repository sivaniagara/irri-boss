import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as AppThems;
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';

import '../../../../core/theme/app_themes.dart';

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
      children:  [
        Expanded(
          child: TimerCard(title: "Run Time", time: (setTime == null || setTime.isEmpty || setTime == "NA") ? "00:00:00" : setTime,),
        ),
        SizedBox(width: 10), // spacing between cards
        Expanded(
          child: TimerCard(title: "Remaining Time",time: (remainingTime == null || remainingTime.isEmpty || remainingTime == "NA") ? "00:00:00" : remainingTime,),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppThemes.primaryColor.withOpacity(0.15),
            // Colors.white.withOpacity(opacity / 2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
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
                  fontWeight: FontWeight.bold, color: Colors.black),
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
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

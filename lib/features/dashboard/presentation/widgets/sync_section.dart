import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';

class SyncSection extends StatelessWidget {
  final String liveSync;
  final String smsSync;
  final int model;

  const SyncSection({super.key, required this.liveSync, required this.smsSync, required this.model});

  @override
  Widget build(BuildContext dialogContext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Live Sync", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(liveSync, style: const TextStyle(fontSize: 12,color: Colors.white)),
          ],
        ),
        ([1, 5].contains(model)) ? ProgramButton(programTitle: 'Program 1') : Container(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("SMS Sync", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(smsSync, style: const TextStyle(fontSize: 12,color: Colors.white)),
          ],
        ),
      ],
    );
  }
}


class ProgramButton extends StatelessWidget {
  final String programTitle;

  const ProgramButton({
    super.key,
    required this.programTitle,
  });

  @override
  Widget build(BuildContext dialogContext) {
    return GlassCard(
      padding:  const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      child: TextButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text('$programTitle clicked!')),
          );
        },
        icon: const Icon(Icons.remove_red_eye, color: Colors.white),
        label: Text(
          programTitle,
          style: const TextStyle(color: Colors.white),
        ),
      
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';

class SyncSection extends StatelessWidget {
  final String liveSync;
  final String smsSync;
  final int model;
  final String deviceId;

  const SyncSection({super.key, required this.liveSync, required this.smsSync, required this.model, required this.deviceId});

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
        ([1, 5].contains(model)) ? ProgramButton(programTitle: 'Program 1', deviceId: deviceId,) : Container(),
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
  final String deviceId;

  const ProgramButton({
    super.key,
    required this.programTitle,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext dialogContext) {
    return GlassCard(
      padding:  const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      child: TextButton.icon(
        onPressed: () {
          dialogContext.push(
              DashBoardRoutes.programPreview,
              extra: deviceId
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
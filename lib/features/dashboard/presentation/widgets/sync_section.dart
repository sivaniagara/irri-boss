import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';

import '../../../../core/theme/app_themes.dart';

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
            Text(liveSync, style: const TextStyle(fontSize: 16,color: AppThemes.primaryColor,fontWeight: FontWeight.bold)),
          ],
        ),
        ([1, 5].contains(model)) ? ProgramButton(programTitle: 'Program 1', deviceId: deviceId,) : Container(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("SMS Sync", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(smsSync, style: const TextStyle(fontSize: 16,color: AppThemes.primaryColor,fontWeight: FontWeight.bold)),
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
      padding:  const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      child: TextButton.icon(
        onPressed: () {
          dialogContext.push(
              DashBoardRoutes.programPreview,
              extra: deviceId
          );
        },
        icon: const Icon(Icons.remove_red_eye, color: AppThemes.primaryColor),
        label: Text(
          programTitle,
        ),

      ),
    );
  }
}
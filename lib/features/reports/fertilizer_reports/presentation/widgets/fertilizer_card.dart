import 'package:flutter/material.dart';
import '../../../../../core/theme/app_themes.dart';
import '../../domain/entities/fertilizer_entities.dart';

class FertilizerCard extends StatelessWidget {
  final FertilizerDatumEntity zone;

  const FertilizerCard(this.zone, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header: Fertilizer Pump Name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppThemes.primaryColor.withOpacity(0.1),
              ),
              child: Text(
                zone.fertPump,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemes.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            
            // Middle Section: Icon and Zone
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.opacity_rounded, 
                        color: AppThemes.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Zone ${zone.zoneNumber}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer: Duration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppThemes.primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    zone.duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

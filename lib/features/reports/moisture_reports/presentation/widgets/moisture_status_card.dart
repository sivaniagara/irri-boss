import 'package:flutter/material.dart';
import '../../domain/entities/moisture_entities.dart';

class MoistureValveCard extends StatelessWidget {
  final int index;
  final MostEntity entity;

  const MoistureValveCard({
    super.key,
    required this.index,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with Serial No and Voltages
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFF8FBFA),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "ID: ${entity.serialNo.padLeft(3, '0')}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00796B),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _iconValue(
                    Icons.battery_std,
                    "${entity.batteryVot}V",
                    Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _iconValue(
                    Icons.wb_sunny_outlined,
                    "${entity.solarVot}V",
                    Colors.amber,
                  ),
                ],
              ),
            ),
            // Body Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Sensor Icon/Visual
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/icons/moisture_sensor_icon.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.sensors,
                          size: 40,
                          color: Color(0xFF00796B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Data Grid
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _dataTile("ADC Value", entity.adcValue, Icons.analytics_outlined),
                            const SizedBox(width: 12),
                            _dataTile("Pressure", "${entity.pressure} bar", Icons.speed),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _dataTile("Moisture 1", "${entity.moisture1} cb", Icons.water_drop_outlined),
                            const SizedBox(width: 12),
                            _dataTile("Moisture 2", "${entity.moisture2} cb", Icons.water_drop_outlined),
                          ],
                        ),
                      ],
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

  Widget _dataTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconValue(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

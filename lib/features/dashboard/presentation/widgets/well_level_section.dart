import 'package:flutter/material.dart';

class WellLevelSection extends StatelessWidget {
  final double level; // e.g. 0–100 (%)
  final double flow;  // e.g. 0.00F

  const WellLevelSection({
    super.key,
    required this.level,
    required this.flow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 120,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3A50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              "Well Level",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                 Positioned.fill(
                  child: Image.asset(
                    'assets/images/common/live_well_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),

                // Percentage text
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF744F26), // brown bar background
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${level.toStringAsFixed(0)} %",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Right-side height text (0.00F)
                Positioned(
                  right: 30,
                  top: 25,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${flow.toStringAsFixed(2)}F",
                      style: const TextStyle(
                        color: Color(0xFF0077B6),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

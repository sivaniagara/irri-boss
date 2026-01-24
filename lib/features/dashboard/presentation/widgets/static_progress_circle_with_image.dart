import 'dart:math';
import 'package:flutter/material.dart';

class StaticProgressCircleWithImage extends StatelessWidget {
  final double progress;          // 0.0 to 1.0
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final Widget? centerWidget;     // usually an Image
  final IconData edgeIcon;
  final Color iconColor;
  final double iconSize;
  final double size;              // overall widget diameter

  const StaticProgressCircleWithImage({
    super.key,
    required this.progress,       // e.g. 0.75
    this.progressColor = Colors.blue,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.strokeWidth = 12,
    this.centerWidget,
    this.edgeIcon = Icons.bolt,
    this.iconColor = Colors.blue,
    this.iconSize = 28,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background circle (gray)
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: 1.0,
              color: backgroundColor,
              strokeWidth: strokeWidth,
            ),
          ),

          // 2. Progress arc
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: progress.clamp(0.0, 1.0),
              color: progressColor,
              strokeWidth: strokeWidth,
            ),
          ),

          // 3. Center image / widget
          if (centerWidget != null)
            SizedBox(
              width: size * 0.55,
              height: size * 0.55,
              child: centerWidget,
            ),

          // 4. Icon on the progress edge
          _buildProgressIcon(),
        ],
      ),
    );
  }

  Widget _buildProgressIcon() {
    // Angle in radians (0 = right, increases clockwise)
    final angle = (progress * 2 * pi) - (pi / 2); // start from top

    final radius = (size / 2) - (strokeWidth / 2);

    final offset = Offset(
      size / 2 + radius * cos(angle),
      size / 2 + radius * sin(angle),
    );

    return Positioned(
      left: offset.dx - iconSize / 2,
      top: offset.dy - iconSize / 2,
      child: Container(
        width: iconSize + 8,
        height: iconSize + 8,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          edgeIcon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,              // start from top
      2 * pi * progress,    // sweep angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
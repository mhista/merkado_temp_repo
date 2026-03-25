import 'dart:ui';
import 'package:flutter/material.dart';

class DashedContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final double borderRadius;
  final Color color;
  final Color borderColor;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  const DashedContainer({
    super.key,
    required this.child,
    required this.height,
    required this.width,
    this.borderRadius = 12,
    this.color = Colors.transparent,
    this.borderColor = Colors.grey,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        borderRadius: borderRadius,
        color: borderColor,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        strokeWidth: strokeWidth,
      ),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.borderRadius,
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _getDashedPath(path, dashWidth, dashSpace);

    canvas.drawPath(dashedPath, paint);
  }

  Path _getDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path path = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        path.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.borderRadius != borderRadius;
}

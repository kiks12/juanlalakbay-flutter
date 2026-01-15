import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/level_node.dart';

class CurvedLevelPathPainter extends CustomPainter {
  final List<LevelNode> nodes;

  CurvedLevelPathPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final paint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(nodes.first.position.dx, nodes.first.position.dy);

    for (int i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1].position;
      final curr = nodes[i].position;

      final controlPoint = Offset(
        (prev.dx + curr.dx) / 2,
        (prev.dy + curr.dy) - 60,
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        curr.dx,
        curr.dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SmoothSCurvePainter extends CustomPainter {
  final List<Offset> points;

  SmoothSCurvePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];

      final midY = (prev.dy + curr.dy) / 2;

      path.cubicTo(prev.dx, midY, curr.dx, midY, curr.dx, curr.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'dart:math' as Math;

import 'package:flutter/widgets.dart';

class LevelNode {
  final Offset position;

  LevelNode(this.position);
}

// Generate level nodes in a w-shaped pattern
List<LevelNode> generateLevelNodes({
  required int count,
  required double width,
}) {
  const double verticalSpacing = 120;
  const double amplitude = 120; // curve strength

  return List.generate(count, (index) {
    final y = index * verticalSpacing + 100;
    final x = width / 2 + amplitude * Math.sin(index * 0.8); // TRUE curve

    return LevelNode(Offset(x, y));
  });
}

// Generate level nodes in an S-shaped pattern
List<Offset> generateSCurvePoints({required int count, required double width}) {
  const double verticalSpacing = 140;
  const double amplitude = 120;

  return List.generate(count, (i) {
    final y = i * verticalSpacing + 100;
    final x =
        width / 2 + amplitude * Math.sin(i * Math.pi / 2); // quarter-wave steps

    return Offset(x, y);
  });
}

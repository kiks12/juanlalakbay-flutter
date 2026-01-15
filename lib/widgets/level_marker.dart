import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/level_state.dart';

class LevelMarker extends StatelessWidget {
  final int level;
  final LevelState state;
  final VoidCallback? onTap;

  const LevelMarker({
    super.key,
    required this.level,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = state == LevelState.locked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _backgroundColor(),
                boxShadow: _shadow(),
                border: Border.all(color: _borderColor(), width: 3),
              ),
              child: Center(child: _icon()),
            ),
            const SizedBox(height: 8),
            Text(
              'Level $level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Icon based on state
  Widget _icon() {
    switch (state) {
      case LevelState.completed:
        return const Icon(Icons.check, color: Colors.white, size: 32);
      case LevelState.current:
        return const Icon(Icons.star, color: Colors.white, size: 32);
      case LevelState.locked:
        return const Icon(Icons.lock, color: Colors.white70, size: 28);
    }
  }

  /// Background color
  Color _backgroundColor() {
    switch (state) {
      case LevelState.completed:
        return Colors.green;
      case LevelState.current:
        return Colors.orange;
      case LevelState.locked:
        return Colors.grey.shade400;
    }
  }

  /// Border color
  Color _borderColor() {
    switch (state) {
      case LevelState.completed:
        return Colors.green.shade700;
      case LevelState.current:
        return Colors.orange.shade700;
      case LevelState.locked:
        return Colors.grey.shade600;
    }
  }

  /// Shadow for depth
  List<BoxShadow> _shadow() {
    if (state == LevelState.locked) return [];

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 4),
        blurRadius: 4,
      ),
    ];
  }
}

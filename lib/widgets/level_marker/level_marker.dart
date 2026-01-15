import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/level_state.dart';

class LevelMarker extends StatefulWidget {
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
  State<LevelMarker> createState() => _LevelMarkerState();
}

class _LevelMarkerState extends State<LevelMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  late Animation<double> _glow;

  bool get isCurrent => widget.state == LevelState.current;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glow = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (isCurrent) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LevelMarker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (isCurrent && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!isCurrent && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = widget.state == LevelState.locked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: isLocked ? null : widget.onTap,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: isCurrent ? _pulse.value : 1.0,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _backgroundColor(),
                      border: Border.all(color: _borderColor(), width: 3),
                      boxShadow: _shadow(),
                    ),
                    child: Center(child: _icon()),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Level ${widget.level}',
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
    switch (widget.state) {
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
    switch (widget.state) {
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
    switch (widget.state) {
      case LevelState.completed:
        return Colors.green.shade700;
      case LevelState.current:
        return Colors.orange.shade700;
      case LevelState.locked:
        return Colors.grey.shade600;
    }
  }

  List<BoxShadow> _shadow() {
    if (widget.state == LevelState.locked) return [];

    if (isCurrent) {
      return [
        BoxShadow(
          color: Colors.orange.withOpacity(_glow.value),
          blurRadius: 20,
          spreadRadius: 4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 4,
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 4),
        blurRadius: 4,
      ),
    ];
  }
}

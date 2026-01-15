import 'package:flutter/material.dart';
import 'package:juanlalakbay/widgets/health_bar.dart';

class Character extends StatefulWidget {
  final int currentHealth; // 0–3
  final HealthBarType type;
  final double size; // width & height
  final String name;

  const Character({
    super.key,
    required this.currentHealth,
    required this.type,
    this.size = 120,
    this.name = '',
  });

  @override
  State<Character> createState() => CharacterState();
}

class CharacterState extends State<Character>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _flashAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Shake tween sequence
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Flash color: normal -> red -> normal repeatedly
    _flashAnimation =
        ColorTween(begin: _normalColor(), end: Colors.red.shade400).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.5, curve: Curves.easeInOut),
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Call this to shake and flash the character when taking damage
  void damageCharacter() {
    _controller.forward(from: 0);
  }

  Color _normalColor() {
    return Colors.blueGrey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Health bar
        _buildHealthBar(),
        const SizedBox(height: 8),

        // Character with shake + flash
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _controller.isAnimating
                      ? _flashAnimation.value
                      : _normalColor(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 6),
                      blurRadius: 6,
                    ),
                  ],
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: Center(
                  child: Text(
                    'CHAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _controller.isAnimating
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        if (widget.name.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ],
    );
  }

  // Simple 3-segment health bar
  Widget _buildHealthBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isFilled = index < widget.currentHealth;
        return Container(
          width: widget.size / 3,
          height: 20,
          decoration: BoxDecoration(
            color: isFilled ? _barColor() : Colors.grey.shade400,
            border: Border.all(color: Colors.black54, width: 1.5),
          ),
        );
      }),
    );
  }

  Color _barColor() {
    return widget.type == HealthBarType.player ? Colors.green : Colors.red;
  }
}

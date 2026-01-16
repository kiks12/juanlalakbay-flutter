import 'package:flutter/material.dart';

enum GameButtonType { normal, success, danger, info }

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final GameButtonType type;
  final bool enabled;

  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.type = GameButtonType.normal, // default
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  LinearGradient get _gradient {
    if (!widget.enabled) {
      return const LinearGradient(
        colors: [Colors.grey, Colors.grey],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    switch (widget.type) {
      case GameButtonType.success:
        return const LinearGradient(
          colors: [Color(0xFFA5D6A7), Color(0xFF4CAF50)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case GameButtonType.danger:
        return const LinearGradient(
          colors: [Color(0xFFEF9A9A), Color(0xFFF44336)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case GameButtonType.info:
        return const LinearGradient(
          colors: [Color(0xFF90CAF9), Color(0xFF2196F3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case GameButtonType.normal:
      default:
        return const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFA000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  Color get _borderColor {
    if (!widget.enabled) return Colors.grey.shade700;

    switch (widget.type) {
      case GameButtonType.success:
        return const Color(0xFF388E3C);
      case GameButtonType.danger:
        return const Color(0xFFD32F2F);
      case GameButtonType.info:
        return const Color(0xFF1976D2);
      case GameButtonType.normal:
      default:
        return const Color(0xFFFF6F00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed();
            }
          : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          0,
          (_isPressed && widget.enabled) ? 6 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: (!widget.enabled || _isPressed)
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 6),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: _gradient,
            border: Border.all(color: _borderColor, width: 3),
          ),
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.6,
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

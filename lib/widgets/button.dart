import 'package:flutter/material.dart';

enum GameButtonType { normal, success, danger, info }

enum GameButtonSize { normal, small }

class GameButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final GameButtonType type;
  final bool enabled;
  final GameButtonSize size;

  const GameButton({
    super.key,
    this.text,
    required this.onPressed,
    this.enabled = true,
    this.type = GameButtonType.normal,
    this.size = GameButtonSize.normal, // DEFAULT
    this.icon,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  // ───────── SIZE CONFIG ─────────
  double get _fontSize => widget.size == GameButtonSize.small ? 14 : 20;
  double get _iconSize => widget.size == GameButtonSize.small ? 18 : 24;

  EdgeInsets get _padding => widget.size == GameButtonSize.small
      ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
      : const EdgeInsets.symmetric(horizontal: 32, vertical: 16);

  double get _radius => widget.size == GameButtonSize.small ? 20 : 30;

  double get _pressOffset => widget.size == GameButtonSize.small ? 4 : 6;

  double get _borderWidth => widget.size == GameButtonSize.small ? 2 : 3;

  // ───────── GRADIENT ─────────
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
        );
      case GameButtonType.danger:
        return const LinearGradient(
          colors: [Color(0xFFEF9A9A), Color(0xFFF44336)],
        );
      case GameButtonType.info:
        return const LinearGradient(
          colors: [Color(0xFF90CAF9), Color(0xFF2196F3)],
        );
      case GameButtonType.normal:
      default:
        return const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFA000)],
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

  Widget _buildGameIcon() {
    return Stack(
      children: [
        // Shadow / outline
        Positioned(
          left: 1.5,
          top: 1.5,
          child: Icon(
            widget.icon,
            size: _iconSize,
            color: Colors.black.withOpacity(0.5),
          ),
        ),

        // Main icon
        Icon(widget.icon, size: _iconSize, color: Colors.white),
      ],
    );
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
          (_isPressed && widget.enabled) ? _pressOffset : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: (!widget.enabled || _isPressed)
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: Offset(0, _pressOffset),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Container(
          padding: _padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            gradient: _gradient,
            border: Border.all(color: _borderColor, width: _borderWidth),
          ),
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.6,
            child: widget.text == null && widget.icon != null
                // ONLY ICON -> center it
                ? Center(child: _buildGameIcon())
                // ICON + TEXT -> keep row
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        _buildGameIcon(),
                        if (widget.text != null) const SizedBox(width: 8),
                      ],
                      if (widget.text != null)
                        Text(
                          widget.text!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 0,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

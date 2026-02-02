import 'package:flutter/material.dart';

class GameText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final Color outlineColor;
  final TextAlign textAlign;

  const GameText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.textColor = Colors.white,
    this.outlineColor = Colors.black,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outline
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = outlineColor,
          ),
          textAlign: textAlign,
        ),
        // Main text
        Text(
          text,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: textColor,
            shadows: const [
              Shadow(
                offset: Offset(0, 3),
                blurRadius: 0,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

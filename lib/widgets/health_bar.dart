import 'package:flutter/material.dart';

enum HealthBarType { player, villain }

class HealthBar extends StatelessWidget {
  final int currentHealth; // 0–3
  final HealthBarType type;

  const HealthBar({super.key, required this.currentHealth, required this.type});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final bool isFilled = index < currentHealth;

        return Container(
          width: 24,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isFilled ? _barColor() : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black54, width: 1.5),
          ),
        );
      }),
    );
  }

  Color _barColor() {
    return type == HealthBarType.player ? Colors.green : Colors.red;
  }
}

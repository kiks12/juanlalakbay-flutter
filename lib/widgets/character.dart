import 'package:flutter/material.dart';
import 'package:juanlalakbay/widgets/health_bar.dart';

class Character extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Health bar
        _buildHealthBar(),

        const SizedBox(height: 8),

        // Character placeholder
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade300,
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
                color: Colors.black54,
              ),
            ),
          ),
        ),

        if (name.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            name,
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
        final isFilled = index < currentHealth;
        return Container(
          width: size / 3,
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
    return type == HealthBarType.player ? Colors.green : Colors.red;
  }
}

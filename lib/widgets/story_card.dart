import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final String story;
  final double width;
  final double height;

  const StoryCard({
    super.key,
    required this.title,
    required this.story,
    this.width = 400,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 6),
            blurRadius: 6,
          ),
        ],
        border: Border.all(color: Colors.orange.shade700, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 1,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Story
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                story,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

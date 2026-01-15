import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/choice.dart';
import 'package:juanlalakbay/models/question.dart';

class QuestionAnswerCard extends StatefulWidget {
  const QuestionAnswerCard({
    super.key,
    required this.question,
    required this.onWrongAnswer,
    required this.onCorrectAnswer,
  });

  final Question question;
  final VoidCallback onWrongAnswer;
  final VoidCallback onCorrectAnswer;

  @override
  State<QuestionAnswerCard> createState() => _QuestionAnswerCardState();
}

class _QuestionAnswerCardState extends State<QuestionAnswerCard> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final buttonWidth =
        ((MediaQuery.of(context).size.width / 1.9) - 64) /
        2; // 16 margin each side + 16 spacing

    // Split 4 choices into 2 rows
    final firstRow = widget.question.choices.sublist(0, 2);
    final secondRow = widget.question.choices.sublist(2, 4);

    Widget buildButton(Choice choice, int index) {
      Color bgColor = Colors.white;

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          if (choice.isAnswer) {
            widget.onCorrectAnswer();
          } else {
            widget.onWrongAnswer();
          }
        },
        child: Container(
          width: buttonWidth,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            gradient: bgColor == Colors.white
                ? const LinearGradient(
                    colors: [Color(0xFFFFF59D), Color(0xFFFFE082)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade700, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              choice.choice,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
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
          // Question
          Text(
            widget.question.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 16),

          // First row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: firstRow
                .asMap()
                .entries
                .map((entry) => buildButton(entry.value, entry.key))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Second row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: secondRow
                .asMap()
                .entries
                .map((entry) => buildButton(entry.value, entry.key + 2))
                .toList(),
          ),
        ],
      ),
    );
  }
}

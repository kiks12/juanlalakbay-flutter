import 'package:flutter/material.dart';
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
  bool answered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// QUESTION CARD - Gamey Version
        Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF59D), Color(0xFFFFE082)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange.shade700, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            widget.question.question,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // ANSWERS CARD - Gamey Version
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(widget.question.choices.length, (index) {
              final choice = widget.question.choices[index];
              final isSelected = selectedIndex == index;

              // Default gradient
              Gradient gradient = const LinearGradient(
                colors: [Color(0xFFFFF59D), Color(0xFFFFE082)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );

              Color borderColor = Colors.orange.shade700;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: GestureDetector(
                  onTap: answered
                      ? null
                      : () {
                          if (choice.isAnswer) {
                            widget.onCorrectAnswer();
                          } else {
                            widget.onWrongAnswer();
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: (answered && isSelected)
                              ? Colors.black.withOpacity(0.25)
                              : Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        choice.choice,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 1,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

import 'package:juanlalakbay/models/choice.dart';

class Question {
  final String question;
  final List<Choice> choices;

  Question({required this.question, required this.choices});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      choices: (json['choices'] as List)
          .map((c) => Choice.fromJson(c))
          .toList(),
    );
  }
}

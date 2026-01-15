class Choice {
  final String choice;
  final bool isAnswer;

  Choice({required this.choice, required this.isAnswer});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      choice: json['choice'] as String,
      isAnswer: json['isAnswer'] as bool,
    );
  }
}

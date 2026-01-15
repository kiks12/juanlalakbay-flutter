import 'package:juanlalakbay/models/question.dart';

enum LevelType { tula, pabula, maiklingKuwento }

LevelType levelTypeFromString(String type) {
  switch (type.toUpperCase()) {
    case 'TULA':
      return LevelType.tula;
    case 'PABULA':
      return LevelType.pabula;
    case 'MAIKLING_KUWENTO':
      return LevelType.maiklingKuwento;
    default:
      throw Exception('Unknown LevelType: $type');
  }
}

class Level {
  final int level;
  final LevelType type;
  final String title;
  final String story;
  final List<String> characters;
  final String setting;
  final List<Question> questions;

  Level({
    required this.level,
    required this.type,
    required this.title,
    required this.story,
    required this.characters,
    required this.setting,
    required this.questions,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      level: json['level'] as int,
      type: levelTypeFromString(json['type']),
      title: json['title'] as String,
      story: json['story'] as String,
      characters: List<String>.from(json['characters']),
      setting: json['setting'] as String,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

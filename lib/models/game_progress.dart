import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class GameProgress {
  @HiveField(0)
  int currentLevel;

  @HiveField(1)
  List<int> completedLevels;

  @HiveField(2)
  List<String> defeatedEnemies = [];

  GameProgress({required this.currentLevel, required this.completedLevels});

  void addDefeatedEnemy(String enemy) {
    defeatedEnemies.add(enemy);
  }
}

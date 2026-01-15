import 'package:hive/hive.dart';
import 'package:juanlalakbay/models/game_progress.dart';

class HiveService {
  HiveService._internal();
  static final HiveService instance = HiveService._internal();

  static const _progressKey = 'gameProgress';

  late Box<GameProgress> gameProgressBox;
  late GameProgress gameProgress;

  Future<void> init() async {
    gameProgressBox = await Hive.openBox<GameProgress>('gameProgressBox');
    gameProgress = loadGameProgress();
  }

  void saveGameProgress(GameProgress progress) {
    gameProgress = progress;
    gameProgressBox.put(_progressKey, progress);
  }

  GameProgress loadGameProgress() {
    return gameProgressBox.get(_progressKey) ??
        GameProgress(currentLevel: 1, completedLevels: []);
  }
}

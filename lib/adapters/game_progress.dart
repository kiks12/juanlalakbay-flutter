import 'package:hive/hive.dart';
import 'package:juanlalakbay/models/game_progress.dart';

class GameProgressAdapter extends TypeAdapter<GameProgress> {
  @override
  final int typeId = 0;

  @override
  GameProgress read(BinaryReader reader) {
    final currentLevel = reader.readInt();
    final completedLevels = reader.readList().cast<int>();
    final defeatedEnemies = reader.readList().cast<String>();

    final progress = GameProgress(
      currentLevel: currentLevel,
      completedLevels: completedLevels,
    );
    progress.defeatedEnemies.addAll(defeatedEnemies);

    return progress;
  }

  @override
  void write(BinaryWriter writer, GameProgress obj) {
    writer.writeInt(obj.currentLevel);
    writer.writeList(obj.completedLevels);
    writer.writeList(obj.defeatedEnemies);
  }
}

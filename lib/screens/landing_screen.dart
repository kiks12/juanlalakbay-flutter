import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/game_progress.dart';
import 'package:juanlalakbay/models/level.dart';
import 'package:juanlalakbay/models/level_state.dart';
import 'package:juanlalakbay/screens/game_start.dart';
import 'package:juanlalakbay/screens/hive_service.dart';
import 'package:juanlalakbay/services/levels_service.dart';
import 'package:juanlalakbay/widgets/button.dart';
import 'package:juanlalakbay/widgets/level_marker.dart';
import 'package:juanlalakbay/widgets/text.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with WidgetsBindingObserver {
  final HiveService hiveService = HiveService.instance;
  final LevelsService levelsService = LevelsService();

  late List<Level> levels = [];
  late GameProgress gameProgress;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    setState(() {
      loading = true;
    });

    loadGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {
        loading = true;
      });
      loadGame();
    } else if (state == AppLifecycleState.paused) {
      // do nothing for now
    }
  }

  Future<void> loadGame() async {
    // Logic to start the game
    await hiveService.init();

    List<Level> loadedLevels = await levelsService.loadJsonData();
    setState(() {
      levels = loadedLevels;
      gameProgress = hiveService.loadGameProgress();
      print("Loaded game progress: Level $gameProgress");

      loading = false;
    });
  }

  LevelState getLevelState(int levelNumber, GameProgress progress) {
    if (levelNumber < progress.currentLevel) {
      return LevelState.completed;
    } else if (levelNumber == progress.currentLevel) {
      return LevelState.current;
    } else {
      return LevelState.locked;
    }
  }

  Level getCurrentLevel() {
    return levels.firstWhere(
      (level) => level.level == gameProgress.currentLevel,
    );
  }

  startGame() {
    // Navigate to the game start screen
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => GameStart(level: getCurrentLevel()),
    );
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (!loading)
          ? Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: levels.map((level) {
                    final state = getLevelState(level.level, gameProgress);
                    return LevelMarker(
                      level: level.level,
                      state: state,
                      onTap: state == LevelState.current ? null : null,
                    );
                  }).toList(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Center(
                      child: GameText(text: "Juan Lalakbay", fontSize: 48),
                    ),
                    Center(
                      child: GameButton(text: "Start", onPressed: startGame),
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

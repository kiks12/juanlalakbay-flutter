import 'package:flutter/material.dart';
import 'package:juanlalakbay/main.dart';
import 'package:juanlalakbay/models/game_progress.dart';
import 'package:juanlalakbay/models/level.dart';
import 'package:juanlalakbay/models/level_node.dart';
import 'package:juanlalakbay/models/level_state.dart';
import 'package:juanlalakbay/screens/game_start.dart';
import 'package:juanlalakbay/screens/hive_service.dart';
import 'package:juanlalakbay/services/levels_service.dart';
import 'package:juanlalakbay/widgets/button.dart';
import 'package:juanlalakbay/widgets/level_marker/level_marker.dart';
import 'package:juanlalakbay/widgets/level_path_painter.dart';
import 'package:juanlalakbay/widgets/text.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with RouteAware {
  final HiveService hiveService = HiveService.instance;
  final LevelsService levelsService = LevelsService();

  late List<Level> levels = [];
  late GameProgress gameProgress;
  bool loading = true;

  final ScrollController _scrollController = ScrollController();
  late List<Offset> nodes;

  @override
  void initState() {
    super.initState();
    loadGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming BACK to this screen
    setState(() => loading = true);

    loadGame().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToCurrentLevel();
      });
    });
  }

  Future<void> loadGame() async {
    // Logic to start the game
    await hiveService.init();

    List<Level> loadedLevels = await levelsService.loadJsonData();
    setState(() {
      levels = loadedLevels;
      gameProgress = hiveService.loadGameProgress();
      print("Loaded game progress: Level $gameProgress");
    });

    // load levels, progress, nodes, etc
    await Future.delayed(const Duration(milliseconds: 100)); // example

    setState(() {
      loading = false;
    });

    // Wait for UI to render, THEN scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToCurrentLevel();
    });
  }

  void scrollToCurrentLevel() {
    final currentIndex = levels.indexWhere(
      (level) => getLevelState(level.level, gameProgress) == LevelState.current,
    );

    if (currentIndex == -1) return;

    final double targetY = nodes[currentIndex].dy;

    final double viewportHeight = MediaQuery.of(context).size.height;

    final double scrollOffset = targetY - (viewportHeight / 2);

    _scrollController.animateTo(
      scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
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

  startGame() {
    // Navigate to the game start screen
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => GameStart(levelNumber: gameProgress.currentLevel),
    );
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    nodes = generateSCurvePoints(count: levels.length, width: screenWidth);

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Scrollable level map
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: nodes.last.dy + 200,
                    child: Stack(
                      children: [
                        // Path
                        CustomPaint(
                          size: Size(screenWidth, nodes.last.dy + 200),
                          painter: SmoothSCurvePainter(nodes),
                        ),

                        // Markers ON the path
                        ...List.generate(levels.length, (index) {
                          final level = levels[index];
                          final state = getLevelState(
                            level.level,
                            gameProgress,
                          );
                          final pos = nodes[index];

                          return Positioned(
                            left: pos.dx - 32,
                            top: pos.dy - 32,
                            child: LevelMarker(
                              level: level.level,
                              state: state,
                              onTap: () {
                                MaterialPageRoute route = MaterialPageRoute(
                                  builder: (context) =>
                                      GameStart(levelNumber: level.level),
                                );
                                Navigator.push(context, route);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Title + Start Button (fixed)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Column(
                    children: [
                      GameText(text: "Juanlalakbay", fontSize: 64),
                      Spacer(),
                      GameButton(text: "Start", onPressed: startGame),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

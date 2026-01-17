import 'package:flutter/material.dart';
import 'package:juanlalakbay/main.dart';
import 'package:juanlalakbay/models/game_progress.dart';
import 'package:juanlalakbay/models/level.dart';
import 'package:juanlalakbay/models/level_node.dart';
import 'package:juanlalakbay/models/level_state.dart';
import 'package:juanlalakbay/screens/certificate_screen.dart';
import 'package:juanlalakbay/screens/game_start.dart';
import 'package:juanlalakbay/screens/hive_service.dart';
import 'package:juanlalakbay/services/levels_service.dart';
import 'package:juanlalakbay/widgets/button.dart';
import 'package:juanlalakbay/widgets/level_marker/level_marker.dart';
import 'package:juanlalakbay/widgets/level_path_painter.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with RouteAware {
  static double offsetX = -84.0;
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
    hiveService.init().then((_) {
      hiveService.resetGameProgress(currentLevel: 4); // For testing
    });
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

  navigateToCertificatesScreen() {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => const CertificateScreen(),
    );
    Navigator.push(context, route);
    // Navigate to certificates screen
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
                // Background image stays fixed
                Image.asset(
                  'assets/backgrounds/background.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Huge overflowing wave
                OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  alignment:
                      Alignment.topCenter, // adjust where the wave "originates"
                  child: Image.asset(
                    'assets/backgrounds/wave.png',
                    fit: BoxFit.cover,
                    width:
                        MediaQuery.of(context).size.width *
                        2, // 2x screen width
                    height:
                        MediaQuery.of(context).size.height *
                        2, // 2x screen height
                    opacity: AlwaysStoppedAnimation(0.2),
                  ),
                ),

                // Scrollable level map
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: nodes.last.dy + 200,
                    child: Stack(
                      children: [
                        // Philippines map now scrolls with content
                        Image.asset(
                          'assets/backgrounds/philippines.png',
                          fit: BoxFit.cover,
                          width: screenWidth,
                          height: nodes.last.dy + 200,
                        ),

                        // Path
                        CustomPaint(
                          size: Size(screenWidth, nodes.last.dy + 200),
                          painter: SmoothSCurvePainter(nodes, offsetX: offsetX),
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
                            left: pos.dx - 32 + offsetX,
                            top: pos.dy - 32,
                            child: LevelMarker(
                              level: level.level,
                              state: state,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GameStart(levelNumber: level.level),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Logo at the top-right corne
                Positioned(
                  top: 20,
                  right: 40,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // background color for the circle
                      border: Border.all(
                        color: Colors.orange.shade700, // circular border
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ),

                // Title + Start Button (fixed)
                Positioned(
                  right: 40,
                  bottom: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // GameText(text: "Juanlalakbay", fontSize: 64),
                      // Spacer(),
                      GameButton(text: "Sulong", onPressed: startGame),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GameButton(
                          text: "Certificates",
                          onPressed: navigateToCertificatesScreen,
                          type: GameButtonType.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

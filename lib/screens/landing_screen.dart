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
import 'package:juanlalakbay/widgets/text.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with RouteAware {
  static String gabay = """
    Ang larong ito ay nag ngangalang JUANLALAKBAY. 

    Paano gamitin:

    1. Pindutin ang lebel 1 para mag simula ka sa kwento na iyong babasahin!
    2. Matapos mong basahin ang kwento sa bawat lebel maaari ka ng magpatuloy sa susunod na hakbang.
    3. Matapos mong mabasa ang kwento ng maayos ay maaari ka ng mag patuloy sa gabay na mga tanong. 
    4. Sagutan mo ng maigi ang mga tanong upang matalo ang iyong kalaban at mag patuloy sa susunod na lebel. 
    5. Pag natapos mo ang bawat lebel maaari mong tignan ang iyong mga natalo at mga sertipiko sa kanang bahagi ng laro. 
    6. Paalala lamang, basahing maigi ang bawat kwento at gabay na tanong upang malampasan mo lahat ng pagsubok na iyong kahaharapin sa bawat lebel.
  """;
  static double offsetX = -84.0;
  final HiveService hiveService = HiveService.instance;
  final LevelsService levelsService = LevelsService();

  late List<Level> levels = [];
  late GameProgress gameProgress;
  bool loading = true;

  final ScrollController _scrollController = ScrollController();
  late List<Offset> nodes;

  bool showGabay = false;

  @override
  void initState() {
    super.initState();
    // hiveService.init().then((_) {
    //   hiveService.resetGameProgress(currentLevel: 10); // For testing
    // });
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
    final screenHeight = MediaQuery.of(context).size.height;

    nodes = generateSCurvePoints(
      count: levels.length,
      width: screenWidth,
      customYOffsets: {
        0: -50,
        1: 10,
        2: 50,
        3: 30,
        4: -10,
        5: 20,
        6: 0,
        7: -80,
      },
      customXOffsets: {
        0: -20,
        1: -40,
        2: -10,
        3: 350,
        4: 20,
        5: 20,
        6: -100,
        7: 320,
      },
    );

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
                        Transform.translate(
                          offset: Offset(
                            offsetX,
                            0,
                          ), // offsetX can be positive or negative
                          child: Image.asset(
                            'assets/backgrounds/philippines.png',
                            fit: BoxFit.cover,
                            width: screenWidth,
                            height: nodes.last.dy + 200,
                          ),
                        ),

                        // Path
                        CustomPaint(
                          size: Size(screenWidth, nodes.last.dy + 200),
                          painter: SmoothSCurvePainter(
                            nodes,
                            offsetX: offsetX * 2,
                          ),
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
                            left: pos.dx - 32 + (offsetX * 2),
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

                Positioned(
                  left: 40,
                  bottom: 40,
                  child: GameButton(
                    type: GameButtonType.info,
                    icon: Icons.question_mark,
                    onPressed: () {
                      setState(() {
                        showGabay = true;
                      });
                    },
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
                      GameButton(
                        text: "Sulong",
                        icon: Icons.play_arrow_rounded,
                        onPressed: startGame,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GameButton(
                          text: "Mga Sertipiko",
                          icon: Icons.book_rounded,
                          onPressed: navigateToCertificatesScreen,
                          type: GameButtonType.info,
                        ),
                      ),
                    ],
                  ),
                ),

                (showGabay)
                    ? Center(
                        child: Container(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.85,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF59D), Color(0xFFFFE082)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 6),
                                blurRadius: 6,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.orange.shade700,
                              width: 3,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GameButton(
                                      size: GameButtonSize.small,
                                      onPressed: () {
                                        setState(() {
                                          showGabay = false;
                                        });
                                      },
                                      icon: Icons.close,
                                    ),
                                  ],
                                ),
                                GameText(text: gabay, fontSize: 15),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
    );
  }
}

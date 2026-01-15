import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/level.dart';
import 'package:juanlalakbay/screens/certificate_screen.dart';
import 'package:juanlalakbay/screens/hive_service.dart';
import 'package:juanlalakbay/services/levels_service.dart';
import 'package:juanlalakbay/widgets/button.dart';
import 'package:juanlalakbay/widgets/character.dart';
import 'package:juanlalakbay/widgets/health_bar.dart';
import 'package:juanlalakbay/widgets/question_answer_card.dart';
import 'package:juanlalakbay/widgets/story_card.dart';
import 'package:juanlalakbay/widgets/text.dart';

class GameStart extends StatefulWidget {
  const GameStart({super.key, required this.levelNumber});

  final int levelNumber;

  @override
  State<GameStart> createState() => _GameStartState();
}

class _GameStartState extends State<GameStart> {
  HiveService hiveService = HiveService.instance;
  LevelsService levelsService = LevelsService();
  late Level level;

  int villainHealth = 3;
  int playerHealth = 3;
  int currentQuestionIndex = 0;

  bool loadingLevel = true;
  bool showStory = true;
  bool showSusunodButton = true;
  bool showLabanText = false;
  bool showWonContent = false;
  bool showLostContent = false;
  bool showTieContent = false;
  bool savingProgress = false;

  @override
  void initState() {
    super.initState();

    loadLevel();
  }

  Future<void> loadLevel() async {
    List<Level> levels = await levelsService.loadJsonData();

    if (widget.levelNumber >= levels.length && mounted) {
      // If level number exceeds available levels
      // show certificate or congrats screen instead
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CertificateScreen()),
      );
      return;
    }

    setState(() {
      level = levels.firstWhere((lvl) => lvl.level == widget.levelNumber);
      // Shuffle questions for randomness
      level.questions.shuffle();
      loadingLevel = false;
    });
  }

  void checkWinLose() {
    if (playerHealth <= 0) {
      // show lose content
      setState(() {
        showLostContent = true;
        showWonContent = false;
        showTieContent = false;
      });
    }

    if (villainHealth <= 0) {
      // show win content and save progress
      setState(() {
        showWonContent = true;
        showLostContent = false;
        showTieContent = false;
      });
      saveProgress();
    }

    if (playerHealth <= 0 && villainHealth <= 0) {
      // show tie content
      setState(() {
        showTieContent = true;
        showLostContent = false;
        showWonContent = false;
      });
    }
  }

  void susunod() {
    // Show LABAN only on first question
    if (showStory && !showLabanText) {
      setState(() {
        showStory = false;
        showLabanText = true;
        showSusunodButton = false;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          showLabanText = false;
        });
      });
      return; // don't proceed to question yet
    }
  }

  void saveProgress() {
    // show saving progress dialog
    setState(() {
      savingProgress = true;
    });

    // Save progress to Hive
    var currentProgress = hiveService.gameProgress;
    currentProgress.completedLevels.add(level.level);
    currentProgress.defeatedEnemies.add(level.characters[1]);
    currentProgress.currentLevel += 1;

    hiveService.saveGameProgress(currentProgress);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        savingProgress = false;
      });
    });
  }

  void onCorrectAnswer() {
    setState(() {
      villainHealth--;
      currentQuestionIndex++;
    });
    checkWinLose();
  }

  void onWrongAnswer() {
    setState(() {
      playerHealth--;
    });
    checkWinLose();
  }

  Widget buildQuizContent() {
    // Show story first
    if (showStory) {
      return StoryCard(title: level.title, story: level.story);
    }

    // Show LABAN
    if (showLabanText) {
      return const Center(child: GameText(text: 'LABAN', fontSize: 64));
    }

    // Show win content
    if (showWonContent) {
      return Column(
        children: [
          const Center(
            child: GameText(
              text: 'Panalo! Napabagsak mo ang kalaban!',
              fontSize: 24,
            ),
          ),
          GameButton(
            text: "Susunod",
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GameStart(levelNumber: widget.levelNumber + 1),
                ),
              );
            },
            type: GameButtonType.success,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GameButton(
              text: "Umalis",
              type: GameButtonType.danger,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    }

    // Show lose content
    if (showLostContent) {
      return Column(
        children: [
          const Center(
            child: GameText(text: 'Talo! Natalo ka sa laban!', fontSize: 24),
          ),
          GameButton(
            text: "Ulitin",
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GameStart(levelNumber: widget.levelNumber),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GameButton(
              text: "Umalis",
              type: GameButtonType.danger,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    }

    // Show tie content
    if (showTieContent) {
      return Column(
        children: [
          const Center(
            child: GameText(
              text: 'Tabla! Walang nanalo sa laban!',
              fontSize: 24,
            ),
          ),
          GameButton(text: "Ulitin", onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GameButton(
              text: "Umalis",
              type: GameButtonType.danger,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    }

    // Show questions
    if (currentQuestionIndex < level.questions.length) {
      return QuestionAnswerCard(
        question: level.questions[currentQuestionIndex],
        onWrongAnswer: onWrongAnswer,
        onCorrectAnswer: onCorrectAnswer,
      );
    }

    // If index >= number of questions, show empty container or "Level Complete"
    return Text("No More Questions");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: GameText(
          text: 'Level ${level.level} - ${level.type.name.toUpperCase()}',
        ),
      ),
      body: (loadingLevel)
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Character(
                      currentHealth: playerHealth,
                      type: HealthBarType.player,
                      name: 'Player',
                    ),
                    buildQuizContent(),
                    Character(
                      currentHealth: villainHealth,
                      type: HealthBarType.villain,
                      name: level.characters[1],
                    ),
                  ],
                ),
                (showSusunodButton)
                    ? Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(16),
                        child: GameButton(onPressed: susunod, text: 'Susunod'),
                      )
                    : Container(),
                (savingProgress)
                    ? Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                GameText(text: 'Saving Progress...'),
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

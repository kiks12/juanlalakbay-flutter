import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/game_progress.dart';
import 'package:juanlalakbay/screens/hive_service.dart';
import 'package:juanlalakbay/widgets/button.dart';
import 'package:juanlalakbay/widgets/text.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  HiveService hiveService = HiveService.instance;
  late GameProgress gameProgress;

  String? selectedCertificate;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadGameProgress();
  }

  void loadGameProgress() async {
    setState(() {
      gameProgress = hiveService.loadGameProgress();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        loading = false;
      });
    });
  }

  List<String> getStoryCertificates() {
    final level = gameProgress.currentLevel;
    final List<String> certs = [];

    if (level > 3) certs.add('TULA');
    if (level > 6) certs.add('PABULA');
    if (level >= 10) certs.add('MAIKLING KUWENTO');

    return certs;
  }

  void _showCertificateDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.orange.shade700, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GameText(text: "Certificate of Achievement", fontSize: 24),
                    const SizedBox(height: 16),
                    GameText(
                      text:
                          "This certifies that you have successfully completed the $title levels.",
                      fontSize: 16,
                    ),
                    const SizedBox(height: 24),
                    GameText(text: "Juanlalakbay", fontSize: 14),
                  ],
                ),
              ),

              // ❌ Close Button
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              width: MediaQuery.of(context).size.width * 2, // 2x screen width
              height:
                  MediaQuery.of(context).size.height * 2, // 2x screen height
              opacity: AlwaysStoppedAnimation(0.2),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 48.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GameText(text: "Defeated Enemies", fontSize: 22),
                      const SizedBox(height: 16),

                      // ───── CHARACTER GRID ─────
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: gameProgress.defeatedEnemies.map((enemy) {
                          return GestureDetector(
                            onTap: () {
                              _showCertificateDialog(enemy);
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black54,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/characters/$enemy.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),
                      GameText(text: "Story Achievements", fontSize: 22),
                      const SizedBox(height: 16),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: getStoryCertificates().map((cert) {
                          return GestureDetector(
                            onTap: () {
                              _showCertificateDialog(cert);
                            },
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black54,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.auto_stories, size: 40),
                                  const SizedBox(height: 8),
                                  GameText(text: cert, fontSize: 14),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top left navigation bar
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: 8.0),
              alignment: Alignment.topLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GameButton(
                    text: "◀",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    type: GameButtonType.info,
                    size: GameButtonSize.small,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GameText(text: 'Certificates', fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:juanlalakbay/models/game_progress.dart';
import 'package:juanlalakbay/screens/hive_service.dart';
import 'package:juanlalakbay/widgets/text.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  HiveService hiveService = HiveService.instance;
  late GameProgress gameProgress;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: GameText(text: "Certificates")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...gameProgress.defeatedEnemies.map((enemy) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade700, width: 3),
                  ),
                  child: Column(
                    children: [
                      GameText(text: "Certificate of Defeat", fontSize: 20),
                      const SizedBox(height: 12),
                      GameText(
                        text:
                            "This certifies that you have bravely defeated the $enemy!",
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

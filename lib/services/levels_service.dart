import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:juanlalakbay/models/level.dart';

class LevelsService {
  LevelsService();

  Future<List<Level>> loadJsonData() async {
    final String response = await rootBundle.loadString(
      'assets/data/levels.json',
    );

    final List<dynamic> decodedJson = jsonDecode(response);

    return decodedJson.map((levelJson) => Level.fromJson(levelJson)).toList();
  }
}

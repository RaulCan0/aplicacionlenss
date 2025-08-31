import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class JsonService {
  static Future<dynamic> loadAssetJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return json.decode(raw);
  }
}

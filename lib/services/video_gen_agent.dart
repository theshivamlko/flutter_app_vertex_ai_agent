import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class VideoGenAgent {
  static final String modalName = 'gemini-2.0-flash';
  static final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(model: modalName);

  static Future<GenerateContentResponse> analyzeVideo(String promptText, Uint8List videoBytes) async {
    try {
      final prompt = TextPart(promptText);
      final videoPart = InlineDataPart('video/mp4', videoBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, videoPart]),
      ], generationConfig: GenerationConfig(responseMimeType: "application/json"));

      return response;
    } catch (e) {
      print("Error generating images: $e");
      rethrow;
    }
  }
}

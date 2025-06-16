import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class ImageGenAgent {
  static final String modalName = 'imagen-3.0-generate-002';
  static late final ImagenModel _imagenModel = FirebaseAI.googleAI().imagenModel(
    model: modalName,
    generationConfig: ImagenGenerationConfig(),
  );

  static Future<Uint8List?> generateImages(String prompt) async {
    try {
      final response = await _imagenModel.generateImages(prompt);
      return response.images.isNotEmpty ? response.images.first.bytesBase64Encoded : null;
    } catch (e) {
      print("Error generating images: $e");
      rethrow;
    }
  }
}

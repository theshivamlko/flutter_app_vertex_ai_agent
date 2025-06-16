import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class VertexAiAgent {
  static final String modalName = 'gemini-2.0-flash-001';
  static final GenerativeModel _model = FirebaseAI.vertexAI().generativeModel(model: modalName);

  static ChatSession? _chatSession;

  static Future<GenerateContentResponse> generateContent(String text) async {
    try {
      final content = [Content.text(text)];
      final response = await _model.generateContent(content);
      return response;
    } catch (e) {
      print("Error generating content: $e");
      rethrow;
    }
  }

  static ChatSession? createChatSession() {
    try {
      _chatSession = _model.startChat();
      return _chatSession;
    } catch (e) {
      print("Error creating chat session: $e");
      return null;
    }
  }

  static Future<GenerateContentResponse> sendMessageToChat(String replyText) async {
    try {
      final message = Content.text(replyText);
      final GenerateContentResponse response = await _chatSession!.sendMessage(message);

      return response;
    } catch (e) {
      print("Error sending message to chat: $e");
      rethrow;
    }
  }

  static Future<GenerateContentResponse> analyzeImage(String prompt, Uint8List image) async {
    try {
      final promptPart = TextPart(prompt);

      final imagePart = InlineDataPart('image/jpeg', image);
      final response = await _model.generateContent([
        Content.multi([promptPart, imagePart]),
      ]);
      return response;
    } catch (e) {
      print("Error analyzing image: $e");
      rethrow;
    }
  }
}

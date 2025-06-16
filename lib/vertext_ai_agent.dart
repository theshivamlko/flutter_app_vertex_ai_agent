import 'package:firebase_ai/firebase_ai.dart';

class VertexAiAgent {
  static final String modalName = 'gemini-2.0-flash-001';
  static final GenerativeModel _model = FirebaseAI.vertexAI().generativeModel(model: modalName);

  static ChatSession? _chatSession;

  static Future<GenerateContentResponse> generateContent(String text) async {
    final content = [Content.text(text)];
    final response = await _model.generateContent(content);
    return response;
  }

  static ChatSession? createChatSession() {
    _chatSession = _model.startChat();
    return _chatSession;
  }

  static Future<GenerateContentResponse> sendMessageToChat(String replyText) async {
    final message = Content.text(replyText);
    final GenerateContentResponse response = await _chatSession!.sendMessage(message);

    return response;
  }
}

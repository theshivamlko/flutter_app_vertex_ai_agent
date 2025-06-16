import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_vertex_ai_agent/chat_model.dart';
import 'package:flutter_app_vertex_ai_agent/vertext_ai_agent.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ValueNotifier<List<ChatModel>> chatMessages = ValueNotifier<List<ChatModel>>([]);

  TextEditingController textEditingController = TextEditingController();

  String type = "Generate Content";

  late ChatSession chatSession;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text("Chat with Vertex Ai")),
      body: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: chatMessages,
          builder: (context, value, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton(
                      isExpanded: true,
                      value: type,
                      underline: SizedBox(),
                      items:
                          ["Generate Content", "Multi Chat"].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                      onChanged: (value) {
                        type = value!;
                        chatMessages.value = [];

                        setState(() {});

                        chatSession = VertexAiAgent.createChatSession()!;
                      },
                    ),
                  ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                        hintText: 'Enter your message',
                        suffix: IconButton(
                          onPressed: () {
                            submitText(textEditingController.text);
                          },
                          icon: Icon(Icons.send),
                        ),
                      ),
                      onSubmitted: (value) {
                        submitText(value);
                      },
                    ),
                  ),
                  ...List.generate(value.length, (index) {
                    return Align(
                      alignment: value[index].type == "modal"
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: value[index].type == "modal"
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            value[index].body,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void submitText(String text) async {
    FocusScope.of(context).unfocus();
    textEditingController.text = "";

    if (type == "Generate Content") {
      generateContent(text);
    } else {
      sendMessageToChat(text);
    }
  }

  void generateContent(String text) async {
    try {
      print("generateContent text $text");
      chatMessages.value = [ChatModel.fromUser(text), ...chatMessages.value];
      GenerateContentResponse generateContentResponse = await VertexAiAgent.generateContent(text);

      print("generateContent response ${generateContentResponse.text}");
      chatMessages.value = [ChatModel.fromModal(generateContentResponse.text ?? "N/A"), ...chatMessages.value];
    } catch (e) {
      print("Error generateContent: $e");
    }
  }

  void sendMessageToChat(String text) async {
    try {
      chatMessages.value = [ChatModel.fromUser(text), ...chatMessages.value];
      GenerateContentResponse generateContentResponse = await VertexAiAgent.sendMessageToChat(text);

      print("multiChat response ${generateContentResponse.text}");
      chatMessages.value = [ChatModel.fromModal(generateContentResponse.text ?? "N / A"), ...chatMessages.value];
    } catch (e) {
      print("Error sendMessageToChat: $e");
    }
  }
}

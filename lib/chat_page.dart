import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_vertex_ai_agent/vertext_ai_agent.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ValueNotifier<List<String>> chatMessages = ValueNotifier<List<String>>([]);

  TextEditingController textEditingController = TextEditingController();

  String type = "Generate Content";

  late ChatSession chatSession;

  @override
  void initState() {
    super.initState();
  }

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
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value[index],
                            style: TextStyle(fontSize: 18, color: index % 2 == 0 ? Colors.black : Colors.deepOrange),
                          ),
                          Divider(thickness: 1),
                        ],
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
    chatMessages.value = [text, ...chatMessages.value];
    GenerateContentResponse generateContentResponse = await VertexAiAgent.generateContent(text);

    print("generateContent response ${generateContentResponse.text}");
    chatMessages.value = [generateContentResponse.text ?? "N/A", ...chatMessages.value];
  }

  void sendMessageToChat(String text) async {
    chatMessages.value = ["User:-  $text", ...chatMessages.value];
    GenerateContentResponse generateContentResponse = await VertexAiAgent.sendMessageToChat(text);

    print("multiChat response ${generateContentResponse.text}");
    chatMessages.value = ["Modal:- ${generateContentResponse.text ?? "N / A"}", ...chatMessages.value];

    final currentHistory = chatSession.history;
  }
}

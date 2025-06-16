import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late GenerativeModel model;

  ValueNotifier<List<String>> chatMessages = ValueNotifier<List<String>>([]);

  TextEditingController textEditingController = TextEditingController();

  String type = "Generate Content";

  late ChatSession chatSession;

  @override
  void initState() {
    super.initState();

    model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.0-flash-001',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Chat with Vertex Ai"),
      ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16,
                    ),
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

                        chatSession = model.startChat();
                      },
                    ),
                  ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
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
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  index % 2 == 0
                                      ? Colors.black
                                      : Colors.deepOrange,
                            ),
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
      multiChat(text);
    }
  }

  void generateContent(String text) async {
    final content = [Content.text(text)];
    chatMessages.value = [text, ...chatMessages.value];

    final response = await model.generateContent(content);

    print("response ${response.text}");
    chatMessages.value = [response.text ?? "N/A", ...chatMessages.value];
  }

  void multiChat(String text) async {
    final message = Content.text(text);
    chatMessages.value = ["User:-  $text", ...chatMessages.value];

    final response = await chatSession.sendMessage(message);

    print("response ${response.text}");
    chatMessages.value = [
      "Modal:- ${response.text ?? "N / A"}",
      ...chatMessages.value,
    ];

    final currentHistory = chatSession.history;
  }
}

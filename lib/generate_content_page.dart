import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_vertex_ai_agent/chat_model.dart';
import 'package:flutter_app_vertex_ai_agent/vertext_ai_agent.dart';

class GenerateContentPage extends StatefulWidget {
  const GenerateContentPage({super.key});

  @override
  State<GenerateContentPage> createState() => _GenerateContentPageState();
}

class _GenerateContentPageState extends State<GenerateContentPage> {
  ValueNotifier<List<ChatModel>> chatMessages = ValueNotifier<List<ChatModel>>([]);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  TextEditingController textEditingController = TextEditingController();

  late ChatSession chatSession;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Generate Content with Vertex Ai"),
      ),
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, value, child) {
          return ValueListenableBuilder(
            valueListenable: chatMessages,
            builder: (context, value, child) {
              return Container(
                height: MediaQuery.of(context).size.height - 150,
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
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
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 300,
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(value.length, (index) {
                              final reversedIndex = value.length - 1 - index;
                              return Align(
                                alignment: value[reversedIndex].type == "modal" ? Alignment.centerLeft : Alignment.centerRight,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: value[reversedIndex].type == "modal" ? Colors.blue.shade100 : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      value[reversedIndex].body,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            isLoading.value ? CircularProgressIndicator() : Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void submitText(String text) async {
    FocusScope.of(context).unfocus();
    textEditingController.text = "";
    generateContent(text);
  }

  void generateContent(String text) async {
    try {
      isLoading.value = true;
      print("generateContent text $text");
      chatMessages.value = [ChatModel.fromUser(text), ...chatMessages.value];
      GenerateContentResponse generateContentResponse = await VertexAiAgent.generateContent(text);

      print("generateContent response ${generateContentResponse.text}");
      chatMessages.value = [ChatModel.fromModal(generateContentResponse.text ?? "N/A"), ...chatMessages.value];
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print("Error generateContent: $e");
    }
  }
}

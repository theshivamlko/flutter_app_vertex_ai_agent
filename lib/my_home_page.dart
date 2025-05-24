import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GenerativeModel model;

  ValueNotifier<List<String>> chatMessages = ValueNotifier<List<String>>([]);

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
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

        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: chatMessages,
          builder: (context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
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
                        Text(value[index], style: TextStyle(fontSize: 18,color: index%2==0?Colors.black:Colors.deepOrange),),
                        Divider()
                      ],
                    ),
                  );
                }),
              ],
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

    final content = [Content.text(text)];
    chatMessages.value=[...chatMessages.value,text];

    final response = await model.generateContent(content);

    print("response ${response.text}");
    chatMessages.value=[...chatMessages.value,response.text ?? "N/A"];

  }
}

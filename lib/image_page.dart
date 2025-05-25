import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  String type = "Analyze Image";
  late GenerativeModel model;
  String output = "";

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
        title: Text("Imagen with Vertex Ai"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                      ["Analyze Image", "Generate Image"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                  onChanged: (value) {
                    type = value!;
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 20),
              type == "Analyze Image" ? getWidget() : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getWidget() {
    return Column(
      children: [
        Center(child: Text("Prompt")),
        SizedBox(height: 20),

        Center(child: Text(analyzePrompt)),

        GestureDetector(
          onTap: () {},
          child: Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Image.asset("assets/image.jpg"),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            analyze();
            setState(() {
              output = "Analyzing...";
            });
          },
          child: Text("Analyze Image"),
        ),

        SizedBox(height: 20),
        Center(child: Text(output)),
      ],
    );
  }

  void analyze() async {
    final prompt = TextPart(analyzePrompt);
    final ByteData image = await rootBundle.load('assets/image.jpg');
    final bytes = image.buffer.asUint8List();
    final imagePart = InlineDataPart('image/jpeg', bytes);

    final response = await model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);
    setState(() {
      output = response.text!;
    });
  }
}

String analyzePrompt = """1. Describe this image in 10 words or less.  
2. How many people are in the image and what are they doing? 
3. What is the main activity happening in the image?""";

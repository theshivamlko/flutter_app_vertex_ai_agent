import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_vertex_ai_agent/image_gen_agent.dart';
import 'package:flutter_app_vertex_ai_agent/vertext_ai_agent.dart';
import 'package:path_provider/path_provider.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  String type = "Analyze Image";
  String output = "";

  String filePath = "";

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,

      builder: (context, snapshot, value) {
        return Scaffold(
          appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text("Imagen with Vertex Ai")),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                  type == "Analyze Image" ? getAnalyzeUi() : getGenerateImageUi(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getAnalyzeUi() {
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
        isLoading.value ? CircularProgressIndicator() : Center(child: Text(output)),
      ],
    );
  }

  Widget getGenerateImageUi() {
    return Column(
      children: [
        Center(child: Text("Prompt")),
        SizedBox(height: 20),
        Center(child: Text(generateImagePrompt)),
        ElevatedButton(
          onPressed: () {
            generateImage();
          },
          child: Text("Generate Image"),
        ),
        SizedBox(height: 20),
        isLoading.value
            ? CircularProgressIndicator()
            : Container(
              height: 300,
              width: 400,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: filePath.isNotEmpty ? Image.file(File(filePath)) : Icon(Icons.image, size: 30),
            ),
      ],
    );
  }

  void analyze() async {
    isLoading.value = true;
    try {
      final ByteData image = await rootBundle.load('assets/image.jpg');
      final bytes = image.buffer.asUint8List();

      final response = await VertexAiAgent.analyzeImage(analyzePrompt, bytes);

      setState(() {
        output = response.text!;
      });
    } catch (e, stack) {
      print("Error analyzing image: $e $stack");
      setState(() {
        output = "Error analyzing image: $e";
      });
    } finally {
      isLoading.value = false;
    }
  }

  void generateImage() async {
    try {
      isLoading.value = true;

      final imageBytes = await ImageGenAgent.generateImages(generateImagePrompt);
      if (imageBytes == null) {
        throw ("No image generated.");
      }

      final Directory? downloadsDir = await getDownloadsDirectory();
      print(downloadsDir?.path);

      final file = File('${downloadsDir?.path}/generated_image.png');
      if (file.existsSync()) {
        file.deleteSync();
      }

      file.createSync();
      await file.writeAsBytes(imageBytes);

      setState(() {
        filePath = file.path;
      });
    } catch (e, stack) {
      print("Error generating image: $e $stack");
    } finally {
      isLoading.value = false;
    }
  }
}

String analyzePrompt = """1. Describe this image in 10 words or less.  
2. How many people are in the image and what are they doing? 
3. What is the main activity happening in the image?""";

String generateImagePrompt =
    """A Golden labrador dog ,sitting on a beach with a sunset in the background and reading newspaper like human.
The beach is sandy with gentle waves in the background and setting sun.
Style of Image should Ghibli like""";

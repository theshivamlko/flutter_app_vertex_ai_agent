import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_vertex_ai_agent/default_options.dart';
import 'package:video_player/video_player.dart';

import '../services/video_gen_agent.dart';

String analyzeVideoPrompt = """
    Analyze given video and provide these outputs on these points:
    1. Utilize time stamps shown in video to understand single activity takes place in video within every 5 secs, only use time stamp that is shown in this video.
    Use "timestamp" key to inform the analysis starting time stamp.  
    2. Understand the activity or events going on this video, and set "category" key to the main activity. Categories can be like "sports", "cooking", "exercise", etc. 
    3. Provide a brief analysis of the activity in "analysis" key, it should be a short description of the activity. Example: "A person is playing football.","A dog is sprinting."
    3. Identify the characters in the analysis,provide their breed in "characters" key. For humans characters will be Male/Female, for animals it will be their breed.
    3. Related "timestamp" and "category" should be put in single JSON Object. Hence multiple activities will from a JSON Array of JSON Objects from "timestamp" and "category"
    
    Output the result in JSON structured format
    """;

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  TextEditingController videoPromptController = TextEditingController(text: analyzeVideoPrompt);
  late VideoPlayerController _controller;

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  String videoPath = "assets/video.mp4";
  String outputJson = "";

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, snapshot, child) {
        return Scaffold(
          appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text("Video Generation")),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: TextField(
                      controller: videoPromptController,
                      maxLines: null,
                      minLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                        hintText: 'Enter your prompt',
                        suffix: IconButton(
                          onPressed: () {
                            submitText(videoPromptController.text);
                          },
                          icon: Icon(Icons.send),
                        ),
                      ),
                      onSubmitted: (value) {
                        submitText(value);
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        VideoPlayer(_controller),
                        Center(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying ? _controller.pause() : _controller.play();
                              });
                            },
                            icon: Icon(
                              _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: () {
                          submitText(videoPromptController.text);
                        },
                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: Text("Analyze")),
                      ),
                  SizedBox(height: 24),
                  Text("Output:"),
                  Text(outputJson),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void submitText(String text) async {
    FocusScope.of(context).unfocus();
    isLoading.value = true;
    _analyzeVideoIsolate();
  }

  void _analyzeVideoIsolate() async {
    try {
      final ByteData image = await rootBundle.load(videoPath);
      final videoBytes = image.buffer.asUint8List();
      GenerateContentResponse response = await VideoGenAgent.analyzeVideo(analyzeVideoPrompt, videoBytes);
      outputJson = response.text ?? "No output received";
      print("Received output $outputJson");
    } catch (e, stack) {
      print(stack);
      outputJson = "Error: ${e.toString()}";
    } finally {
      isLoading.value = false;
      setState(() {});
    }
  }
}

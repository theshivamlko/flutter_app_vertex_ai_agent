import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_vertex_ai_agent/image_page.dart';
import 'chat_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'default_options.dart';
import 'generate_content_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultOptions.currentPlatform(dotenv.env));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter with Vertex AI Agent',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedIndex,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: selectedIndex.value,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.format_textdirection_l_to_r), label: 'Text Content'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Image'),
            ],
            onTap: (value) {
              selectedIndex.value = value;
              setState(() {

              });
            },
          ),
          body: getBody(),
        );
      },
    );
  }

  Widget getBody() {
    return IndexedStack(index: selectedIndex.value, children: [GenerateContentPage(), ChatPage(), ImagePage()]);
  }
}

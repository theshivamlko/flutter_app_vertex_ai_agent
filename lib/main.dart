import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_vertex_ai_agent/screens/image_page.dart';
import 'package:flutter_app_vertex_ai_agent/screens/video_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'default_options.dart';
import 'screens/chat_page.dart';
import 'screens/generate_content_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  DefaultFirebaseOptions.loadFirebaseApp(dotenv.env);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.format_textdirection_l_to_r), label: 'Content'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Image'),
              BottomNavigationBarItem(icon: Icon(Icons.slow_motion_video_outlined), label: 'Video'),
            ],
            onTap: (value) {
              selectedIndex.value = value;
              setState(() {});
            },
          ),
          body: getBody(),
        );
      },
    );
  }

  Widget getBody() {
    return IndexedStack(index: selectedIndex.value, children: [GenerateContentPage(), ChatPage(), ImagePage(), VideoScreen()]);
  }
}

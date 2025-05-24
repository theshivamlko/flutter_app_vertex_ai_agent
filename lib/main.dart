import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'my_home_page.dart';

void main() async{

    const String androidApiKey = String.fromEnvironment('androidApiKey', defaultValue: 'default_key');



  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(apiKey: androidApiKey,
          appId: "1:542049090470:android:6a5f61d4091fb47c946d67",
          messagingSenderId: "542049090470", projectId: "starlit-primacy-460716-t2")
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


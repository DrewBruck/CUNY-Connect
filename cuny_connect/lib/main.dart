import 'package:cuny_connect/auth/auth_gate.dart';
import 'package:cuny_connect/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cuny_connect/utils/message.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(ChatMessageAdapter()); // Register your ChatMessage adapter
  await Hive.openBox<ChatMessage>('messages'); // Open a box to store ChatMessage objects
  
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color.fromARGB(255, 63, 4, 73),
      ),
      home: const AuthGate(),
    );
  }
}

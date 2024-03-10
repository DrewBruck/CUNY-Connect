import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true, //turns debug corner on/off
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Color.fromARGB(255, 63, 4, 73),
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page', style: TextStyle(color: Colors.white)),
        backgroundColor:
            Theme.of(context).primaryColor, // Explicitly set background color
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.chat_outlined, color: Colors.white),
              label: "Chats"),
          NavigationDestination(
            icon: Icon(Icons.calendar_month, color: Colors.white),
            label: "Schedule",
          ),
        ],
      ),
    );
  }
}

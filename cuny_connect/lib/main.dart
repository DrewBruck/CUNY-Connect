import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //turns debug corner on/off
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color.fromARGB(255, 63, 4, 73),
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
        leading: const Icon(Icons.add_circle, color: Colors.white),
        title:
            const Text('CUNY Connect', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.search),
              color: Colors.white),
          IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.person_outlined),
              color: Colors.white),
        ],
        centerTitle: true,
        backgroundColor:
            Theme.of(context).primaryColor, // Explicitly set background color
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Schedule",
          ),
        ],
      ),
    );
  }
}

import 'package:cuny_connect/pages/schedule.dart';
import 'package:flutter/material.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'profile.dart';
import 'conversation_creator.dart';
import 'chat_log_page.dart';  // Importing ChatLogPage
import 'package:cuny_connect/models/CUNYUser.dart';

// StatefulWidget is the superclass
// StatefulWidget useful for dynamic integration.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // _HomePageState is private since '_' is at the front.
  // Note => is used as a single expression function.
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //////////////////////////////////////////////////////////////////////////////
  /// Internal Variables

  // We can only set FirebaseService once and cannot be reassigned later.
  final FirebaseService firebaseService = FirebaseService();
  int _selectedIndex = 0;

  // Widget that deals with all the conversations.
  List<Widget> _widgetOptions() => [
    FutureBuilder<CUNYUser?>(
      future: firebaseService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        return ChatLogPage();  // Assuming user is successfully fetched, show chat log.
      },
    ),
    const SchedulePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Code to trigger a new text message or navigate to a message composition page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConversationCreator()),
            );
          },
          icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        ),
        title: const Text('CUNY Connect', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 36.0, 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              icon: const Icon(Icons.person_outlined, color: Colors.white),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_rounded),
            label: "Schedule",
          ),
          // Add more BottomNavigationBarItem as needed
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'chat_page.dart';
import 'profile.dart';
import 'package:cuny_connect/models/CUNYUser.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Code to trigger a new text message or navigate to a message composition page
          },
          icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        ),
        title: const Text('CUNY Connect', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              // Code to handle search action
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
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
      body: FutureBuilder<CUNYUser?>(
        future: firebaseService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            // Check if there's at least one conversation ID
            if (snapshot.data?.conIDs.isNotEmpty == true) {
              // For simplicity, showing the first conversation
              String firstConversationId = snapshot.data!.conIDs.first;
              return ChatPage(conversationId: firstConversationId);
            } else {
              return const Center(child: Text("No conversations found."));
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
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


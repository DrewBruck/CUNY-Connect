import 'package:flutter/material.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:cuny_connect/pages/chat_page.dart';
import 'package:cuny_connect/utils/conversation.dart';

class ChatLogPage extends StatefulWidget {
  final FirebaseService _firebaseService = FirebaseService();

  ChatLogPage({super.key});

  @override
  _ChatLogPageState createState() => _ChatLogPageState();
}

class _ChatLogPageState extends State<ChatLogPage> {
  late Stream<List<Conversation>> _conversationsStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _conversationsStream = widget._firebaseService.conversationsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.black)),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: _conversationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching conversations: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No conversations found."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var conversation = snapshot.data![index];
                String lastMessageContent = conversation.messages.isNotEmpty
                  ? conversation.messages.last.content
                  : "No messages";
                bool isAdmin = conversation.isAdmin;
                String adminTitle = conversation.adminTitle;

                return FutureBuilder<String>(
                  future: widget._firebaseService.formatParticipantNames(conversation.participants),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text("Loading..."),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${snapshot.error}'),
                      );
                    }

                    String participants = snapshot.data ?? "Unknown";
                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(isAdmin ? adminTitle[0] : (participants.isNotEmpty ? participants[0] : '?'),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        title: Text(isAdmin ? adminTitle : participants, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lastMessageContent, style: TextStyle(color: Colors.grey[600])),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ChatPage(conversationId: conversation.conversationIds),
                          )).then((value) => setState(() {
                            // Refresh the stream when coming back to this page
                            _initializeStream();
                          }));
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

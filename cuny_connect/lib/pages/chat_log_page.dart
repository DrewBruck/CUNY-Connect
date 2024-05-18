import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:cuny_connect/pages/chat_page.dart';
import 'package:cuny_connect/utils/conversation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cuny_connect/pages/socket_service.dart';

class ChatLogPage extends StatefulWidget {
  final FirebaseService _firebaseService = FirebaseService();

  ChatLogPage({super.key});

  @override
  _ChatLogPageState createState() => _ChatLogPageState();
}

class _ChatLogPageState extends State<ChatLogPage> {
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _initializeConversations();
  }

  Future<void> _initializeConversations() async {
    await Hive.openBox<Conversation>('conversations');
    var conversationBox = Hive.box<Conversation>('conversations');
    if (mounted) {
      setState(() {
        _conversations = conversationBox.values.toList();
      });
    }

    try {
      var conversationsFromFirebase = await widget._firebaseService.fetchConversations();
      for (var conversation in conversationsFromFirebase) {
        conversationBox.put(conversation.conversationIds, conversation);
      }
      if (mounted) {
        setState(() {
          _conversations = conversationBox.values.toList();
        });
      }
    } catch (e) {
      print("Error fetching conversations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.black)),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      body: Consumer<SocketService>(
        builder: (context, socketService, child) {
          return ValueListenableBuilder(
            valueListenable: Hive.box<Conversation>('conversations').listenable(),
            builder: (context, Box<Conversation> box, _) {
              var conversations = box.values.toList();
              conversations.sort((a, b) {
                if (a.messages.isNotEmpty && b.messages.isNotEmpty) {
                  return b.messages.last.timestamp.compareTo(a.messages.last.timestamp);
                } else if (a.messages.isEmpty && b.messages.isNotEmpty) {
                  return 1; // a is empty, so b comes first
                } else if (a.messages.isNotEmpty && b.messages.isEmpty) {
                  return -1; // b is empty, so a comes first
                } else {
                  return 0; // both are empty
                }
              });

              if (conversations.isEmpty) {
                return const Center(child: Text("No conversations found."));
              }

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  if (index >= conversations.length) {
                    return Container(); // Safeguard against index out of range
                  }

                  var conversation = conversations[index];
                  int numberOfReceivers = conversation.messages.isNotEmpty
                      ? conversation.messages.last.receiverId.length
                      : 0;
                  String lastMessageContent = conversation.messages.isNotEmpty
                      ? conversation.messages.last.content
                      : "No messages";
                  if (lastMessageContent.length > 100) {
                    lastMessageContent = "${lastMessageContent.substring(0, 100)}...";
                  }
                  String formattedTime = conversation.messages.isNotEmpty
                      ? _formatMessageTime(conversation.messages.last.timestamp)
                      : "No Date";
                  bool isAdmin = conversation.isAdmin;
                  String adminTitle = conversation.adminTitle;

                  return Column(
                    children: [
                      FutureBuilder<String>(
                        future: widget._firebaseService.formatParticipantNames(conversation.participants),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text("Loading..."));
                          } else if (snapshot.hasError) {
                            return ListTile(title: Text('Error: ${snapshot.error}'));
                          }

                          String participants = snapshot.data ?? "Unknown";
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                (numberOfReceivers > 1 || isAdmin) ? adminTitle[0] : (participants.isNotEmpty ? participants[0] : '?'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: (numberOfReceivers > 1 || isAdmin) ? "$adminTitle " : participants,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isAdmin)
                                          const TextSpan(
                                            text: ' [Course Chat]',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(128, 0, 0, 1),
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(formattedTime, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                            subtitle: Text(lastMessageContent, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ChatPage(conversationId: conversation.conversationIds),
                              ));
                            },
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 69.0),
                        child: Divider(color: Colors.grey, height: 0.25),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aWeekAgo = today.subtract(const Duration(days: 7));

    if (timestamp.isAfter(today)) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (timestamp.isAfter(aWeekAgo)) {
      return DateFormat('EEE').format(timestamp);
    } else if (timestamp.year == now.year) {
      return DateFormat('MMMM d').format(timestamp);
    } else {
      return DateFormat('MMMM d, yyyy').format(timestamp);
    }
  }
}

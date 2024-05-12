import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:cuny_connect/pages/chat_page.dart';
import 'package:cuny_connect/utils/conversation.dart';
import 'dart:async';

class ChatLogPage extends StatefulWidget {
  final FirebaseService _firebaseService = FirebaseService();

  ChatLogPage({super.key});

  @override
  _ChatLogPageState createState() => _ChatLogPageState();
}

class _ChatLogPageState extends State<ChatLogPage> {
  late Stream<List<Conversation>> _conversationsStream;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeStream();
    //_startAutoRefresh();
    widget._firebaseService.listenForConversationChanges();
  }

  void _startAutoRefresh(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if(mounted){
        if(kDebugMode){
          print("Test this out!");
        }
        setState(() {
          _initializeStream();
        });
      }
    });
  }

  void _initializeStream() {
    _conversationsStream = widget._firebaseService.conversationsStream();
  }


  @override
  void didUpdateWidget(covariant ChatLogPage oldWidget){
    super.didUpdateWidget(oldWidget);
    if(oldWidget._firebaseService.userId != widget._firebaseService.userId){
      if(kDebugMode){
        print('User ID has changed. Reinitializing stream.');
      }
      _initializeStream();
    }else{
      if(kDebugMode){
        print('No significant changes in properties.');
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.black)),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      body: StreamBuilder<List<Conversation>>(
        stream:  _conversationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching conversations: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No conversations found."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var conversation = snapshot.data![index];
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
                            child: Text((numberOfReceivers > 1 || isAdmin) ? adminTitle[0] : (participants.isNotEmpty ? participants[0] : '?'),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                      if (isAdmin) // Conditional tag for official business
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
                            )).then((value) => setState(() {
                              _initializeStream();
                            }));
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
          }
        },
      ),
    );
  }
}

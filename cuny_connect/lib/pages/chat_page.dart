import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cuny_connect/utils/message.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:cuny_connect/utils/conversation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cuny_connect/pages/socket_service.dart';
import 'package:cuny_connect/pages/profile.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  const ChatPage({super.key, required this.conversationId});

  @override
  _ChatPageState createState() => _ChatPageState(conversationId);
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> _messages = [];
  final String conversationId;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  List<String> receiverNames = [];
  final FirebaseService firebaseService = FirebaseService();
  String title = "";
  String senderName = "";
  Map<int, String> cachedNames = {};

  _ChatPageState(this.conversationId);

  @override
  void initState() {
    super.initState();
    _fetchAndSetTitle();
    _loadMessages();
  }

  Future<void> _fetchAndSetTitle() async {
    String name = await _loadTitle();
    if (mounted) {
      setState(() {
        title = name;
      });
    }
  }

  Future<String> _loadTitle() async {
    senderName = await firebaseService.getUserName(userID);
    Map<String, dynamic> adminDetails = await firebaseService.fetchAdminDetails(conversationId);
    bool isAdmin = adminDetails["isAdmin"];

    receiverNames = await firebaseService.fetchParticipants(conversationId);
    receiverNames.removeWhere((id) => id == userID);

    if (receiverNames.isNotEmpty && receiverNames.length < 2) {
      if (!isAdmin) {
        return await firebaseService.getUserName(receiverNames.first);
      }
    }

    return adminDetails['adminTitle'] ?? '';
  }

  Future<void> _loadMessages() async {
    final box = await Hive.openBox<ChatMessage>('messages_$conversationId');
    if (box.isEmpty) {
      final conversationRef = FirebaseFirestore.instance.collection('Conversations').doc(conversationId);
      try {
        final messagesSnapshot = await conversationRef.collection('messages').orderBy('timestamp').get();
        final List<ChatMessage> tempMessages = [];
        for (var doc in messagesSnapshot.docs) {
          final message = ChatMessage.fromFirestore(doc.data(), doc.id);
          tempMessages.add(message);
          await box.add(message);
        }
        if (mounted) {
          setState(() {
            _messages = tempMessages.reversed.toList();
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error loading messages: $e');
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _messages = box.values.toList().reversed.toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    bool isGroupChat = receiverNames.length > 1;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: InkWell(
          onTap: () {
            if (isGroupChat) {
              _showParticipantsDialog();
            } else {
              if (receiverNames.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: receiverNames.first)));
              }
            }
          },
          child: Text(title, style: const TextStyle(color: Colors.white)),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<ChatMessage>('messages_$conversationId').listenable(),
              builder: (context, Box<ChatMessage> box, _) {
                _messages = box.values.toList().reversed.toList();
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    if (index >= _messages.length) return Container();
                    final message = _messages[index];
                    final formattedTime = DateFormat('yyyy-MM-dd – hh:mm a').format(message.timestamp);
                    bool isSentByUser = (message.senderId == userID);
                    print(message.senderName);

                    // Check if this is the last element in the list
                    bool isLastElement = index == _messages.length - 1;

                    // Check if the current message sender is different from the previous one
                    bool isDifferentSender = index < _messages.length - 1 && _messages[index + 1].senderId != message.senderId;

                    return Column(
                      children: [
                        if (isLastElement && isGroupChat)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[300], height: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    _messages[_messages.length - 1].senderName.toUpperCase(),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[300], height: 1),
                                ),
                              ],
                            ),
                          ),
                        if (isDifferentSender && isGroupChat)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[300], height: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    _messages[index].senderName.toUpperCase(),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[300], height: 1),
                                ),
                              ],
                            ),
                          ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double maxWidth = constraints.maxWidth * 0.70;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Column(
                                crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: maxWidth),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                          margin: const EdgeInsets.only(left: 10, right: 10),
                                          decoration: BoxDecoration(
                                            color: isSentByUser ? Colors.purple[100] : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.content,
                                                style: const TextStyle(color: Colors.black),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formattedTime,
                                                style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(socketService),
        ],
      ),
    );
  }

  Widget _buildMessageInput(SocketService socketService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Send a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                socketService.sendMessage(conversationId, _controller.text.trim(), receiverNames, senderName);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showParticipantsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Participants'),
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              itemCount: receiverNames.length,
              itemBuilder: (BuildContext context, int index) {
                final userId = receiverNames[index];
                return FutureBuilder<String>(
                  future: cachedNames.containsKey(index) ? Future.value(cachedNames[index]) : firebaseService.getUserName(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        cachedNames[index] = snapshot.data!;
                        return ListTile(
                          title: Text(snapshot.data!),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ProfilePage(userId: userId),
                            ));
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const ListTile(
                          title: Text('Error loading'),
                        );
                      }
                    }
                    return const ListTile();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
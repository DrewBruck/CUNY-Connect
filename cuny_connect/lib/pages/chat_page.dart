import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cuny_connect/utils/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isConnected = true;
  IO.Socket? socket;
  List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    connectToServer();
  }

  void _loadMessages() async {
    final box = Hive.box<ChatMessage>('messages');
    setState(() {
      _messages = box.values.toList();
    });
  }

  @override
  void dispose() {
    disconnectFromServer();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void connectToServer() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
    
    socket!.onConnect((_) => print('Connected'));
    
    socket!.on('msg', (data) {
      if (data['receiverId'] == "currentUserId") {
        setState(() {
          _messages.add(ChatMessage(
            messageId: data['messageId'],
            senderId: data['senderId'],
            receiverId: data['receiverId'],
            content: data['content'],
            timestamp: DateTime.parse(data['timestamp']),
          ));
        });
      }
    });
    
    socket!.onDisconnect((_) => print('Disconnected'));
  }

  void disconnectFromServer() {
    socket?.disconnect();
  }

  void sendMessageToServer(String content) {
    if (socket != null && _isConnected) {
      final messageId = UniqueKey().toString();
      final senderId = "0000000"; // Actual sender ID logic needed
      final receiverId = "receiverUserId"; // Actual receiver ID logic needed
      
      final message = ChatMessage(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
      );
      
      final box = Hive.box<ChatMessage>('messages');
      box.add(message);
      
      setState(() {
        _messages.insert(0,message);
      });
      
      socket!.emit('msg', {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': message.timestamp.toIso8601String(),
      });

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.link_off : Icons.link),
            onPressed: _toggleConnection,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final formattedTime = DateFormat('yyyy-MM-dd – hh:mm a').format(message.timestamp);
                bool isSentByUser = (message.senderId == "currentUserId"); // Actual logic needed

                return Align(
                  alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal:12.0, vertical: 8.0),
                    margin: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                      color: isSentByUser ? Colors.purple[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15.0),
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
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
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
                sendMessageToServer(_controller.text.trim());
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _toggleConnection() {
    if (_isConnected) {
      disconnectFromServer();
    } else {
      connectToServer();
    }
    setState(() {
      _isConnected = !_isConnected;
    });
  }
}




// Conversations/
// ├─ conversationID/
// │  ├─ message/
// │  │  ├─ messageID/
// │  │  │  ├─ content
// │  │  │  ├─ receiverID
// │  │  │  ├─ senderID
// │  │  │  ├─ timeStamp
// │  │  ├─ lastMessage
// │  │  ├─ lastMessageTime
// │  │  ├─ participants/

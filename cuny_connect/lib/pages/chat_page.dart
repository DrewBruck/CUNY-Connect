import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/utils/message.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  const ChatPage({super.key, required this.conversationId});

  @override
  _ChatPageState createState() => _ChatPageState(conversationId);
}

class _ChatPageState extends State<ChatPage> {
  bool _isConnected = true;
  IO.Socket? socket;
  List<ChatMessage> _messages = [];
  final String conversationId;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  List<String> receiverNames = [];
  final FirebaseService firebaseService = FirebaseService();
  String title = "";
  _ChatPageState(this.conversationId);

  @override
  void initState() {
    super.initState();
    _fetchAndSetTitle();
    _loadMessages();
    connectToServer();
  }

  Future<String> _loadTitle() async {
    receiverNames = await firebaseService.fetchParticipants(conversationId);
    String title = await firebaseService.getUserName(receiverNames[1]);
    return title;
  }

  void _fetchAndSetTitle() async{
    String name =  await _loadTitle();
    setState((){
      title = name;
    });
  }

  void _loadMessages() async {
    final box = await Hive.box<ChatMessage>('messages');
    if(box.isEmpty) {
      // Fetch messages from Firestore
      final conversationRef = FirebaseFirestore.instance.collection(
          'Conversations').doc(conversationId);

      final messagesSnapshot = await conversationRef.collection('messages')
          .orderBy('timestamp')
          .get();

      // Temp list to hold the messages before updating the state.
      final List<ChatMessage> tempMessages = [];

      // Iterate over the documents in the snapshot.
      for (var doc in messagesSnapshot.docs) {
        final message = ChatMessage.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
        tempMessages.add(message);

        // Store the message in Hive.
        await box.add(message);
      }

      setState(() {
        _messages = box.values.toList().reversed.toList();;
      });
    }

    else{
      final messages = box.values.toList().reversed.toList();
      setState(() {
        _messages = messages;
      });
    }
  }

  @override
  void dispose() {
    disconnectFromServer();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void connectToServer() {
    socket = IO.io('http://45.79.155.215:3001', <String, dynamic>{
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

  void sendMessageToServer(String content) async{
    if (socket != null && _isConnected) {
      final messageId = UniqueKey().toString();
      final senderId = userID;
      final List<String> receiverIds = receiverNames;
      
      final message = ChatMessage(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverIds,
        content: content,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('Conversations').doc(conversationId).collection('messages').doc(messageId).set({
        'senderId': senderId,
        'receiverId': receiverIds,
        'content': content,
        'timestamp': DateTime.now(),
      });

      final box = Hive.box<ChatMessage>('messages');
      box.add(message);
      
      setState(() {
        _messages.insert(0,message);
      });
      
      socket!.emit('msg', {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverIds,
        'content': content,
        'timestamp': message.timestamp.toIso8601String(),
      });

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                bool isSentByUser = (message.senderId == userID); // Actual logic needed

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




// Conversations            : Collection
// ├─ conversationID        : String
// │  ├─ participants       : Array
// │  ├─ messages           : Sub-Collection
// │  │  ├─ messageID       : String
// │  │  │  ├─ content      : String
// │  │  │  ├─ receiverID   : Array
// │  │  │  ├─ senderID     : String 
// │  │  │  ├─ timeStamp    : String




// conversationRef.get().then((docSnapshot){
//   if(docSnapshot.exists){
//     print("Document Data: ${docSnapshot.data()}");
//   }else{
//     print("Document does not exist!!!!!!!!!!!!");
//   }
// }).catchError((error){
//   print("ERROR: $error");
// });
// conversationRef.collection('messages').get().then((docSnapshot){
//   if(docSnapshot.docs.isEmpty){
//     print("No messages found in this conversation.");
//   }else{
//     for(var doc in docSnapshot.docs) {
//       print("MessageID: ${doc.id}, Data: ${doc.data()}");
//     }
//   }
// }).catchError((error){
//   print("ERROR: $error");
// });
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuny_connect/pages/profile.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuny_connect/utils/message.dart';

import '../utils/conversation.dart';

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
      // Fetch admin details if needed
      Map<String, dynamic> adminDetails = await firebaseService.fetchAdminDetails(conversationId);
      bool isAdmin = adminDetails["isAdmin"];

      receiverNames = await firebaseService.fetchParticipants(conversationId);
      receiverNames.removeWhere((id) => id == userID);

      if (!isAdmin) {
        if (receiverNames.isNotEmpty) {
          String title = await firebaseService.getUserName(receiverNames.first);
          return title;
        }
      }
      
      // Return adminTitle or empty if not available
      return adminDetails['adminTitle'] ?? ''; 
  }


  void _fetchAndSetTitle() async{
    String name =  await _loadTitle();
    if(mounted){
      setState((){
        title = name;
      });
    }
  }

  void _loadMessages() async {
    print("SET UP MESSAGES");
    final box = await Hive.openBox<ChatMessage>('messages_$conversationId');
    if(box.isEmpty) {
      // Fetch messages from Firestore
      final conversationRef = FirebaseFirestore.instance.collection(
          'Conversations').doc(conversationId);

      try {
        final messagesSnapshot = await conversationRef.collection('messages')
            .orderBy('timestamp')
            .get();

        print('READ MESSAGES');
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
        if(mounted){
          setState(() {
            _messages = box.values.toList().reversed.toList();;
          });
        }
      }catch(e){
        if (e is FirebaseException) {
          print('Firebase Exception: ${e.code} - ${e.message}');
        } else {
          print('Unexpected error: $e');
        }
      }
    }

    else{
      final messages = box.values.toList().reversed.toList();
      if(mounted){
        setState(() {
          _messages = messages;
        });
      }
    }
  }


  @override
  void dispose() {
    Hive.box<ChatMessage>('messages_${conversationId}').close();  // Close the specific Hive box
    disconnectFromServer();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void connectToServer() {
    socket = IO.io('https://45-79-155-215.ip.linodeusercontent.com:3001/',{
      'transports': ['websocket'],
      'autoConnect' : true   // LETS US WORK IN DART DEMO!!
    });
    socket!.connect();

    socket!.onConnect((_) => print('Connected'));

    socket!.on('broadcast', (data) {
      if (data['receiverId'].first == userID && mounted) {
        setState(() {
          _messages.insert(0, ChatMessage(
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
      final List<String> authUsers = receiverNames;
      authUsers.add(senderId);

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

      final box = Hive.box<ChatMessage>('messages_$conversationId');
      box.add(message);

      if(mounted){
        setState(() {
          _messages.insert(0,message);
        });
      }

      socket!.emit('msg', {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverIds,
        'content': content,
        'timestamp': message.timestamp.toIso8601String(),
      });

    }
  }

void _showParticipantsDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Participants'),
        content: Container(
          width: double.minPositive, // Set the width to minimum if necessary
          height: 300, // Set a fixed height or make it dynamic based on content
          child: ListView.builder(
            itemCount: receiverNames.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<String>(
                future: firebaseService.getUserName(receiverNames[index]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return ListTile(
                      title: Text(snapshot.data!),
                      onTap: () {
                        Navigator.of(context).pop(); // Close the dialog first
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfilePage(userId: receiverNames[index]),
                        ));
                      },
                    );
                  } else if (snapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading'),
                    );
                  }
                  return ListTile(
                    title: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  // Determine if it's a group chat
  bool isGroupChat = receiverNames.length > 1;
  String lastSenderId = ""; // Initialize an empty string to keep track of the last message's sender

  return Scaffold(
    appBar: AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: InkWell(
        onTap: () {
          if (isGroupChat) {
            _showParticipantsDialog();
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: receiverNames.first)));
          }
        },
        child: Text(title, style: TextStyle(color: Colors.white)),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
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
              bool isSentByUser = (message.senderId == userID);
              bool shouldDisplaySenderName = isGroupChat && (lastSenderId != message.senderId);
              lastSenderId = message.senderId; // Update lastSenderId to the current one for the next iteration

              return LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth * 0.70;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (shouldDisplaySenderName)
                                FutureBuilder<String>(
                                  future: firebaseService.getUserName(message.senderId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                      return Container(
                                        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 1),
                                        child: Text(
                                          snapshot.data!,
                                          style: TextStyle(color: Colors.grey[700]),
                                          textAlign: isSentByUser ? TextAlign.right : TextAlign.left,
                                        ),
                                      );
                                    } else {
                                      return const SizedBox(); // Placeholder widget
                                    }
                                  },
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                margin: EdgeInsets.only(left: isSentByUser ? 10 : 10, right: isSentByUser ? 10 : 10),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
    if(mounted){ // Part of the StatefulWidget class.
      setState(() {
        _isConnected = !_isConnected;
      });
    }
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

// final messagesSnapshot = await FirebaseFirestore.instance.doc(
// '/Conversations/RVYBfcgdVON6paEWTsrW/messages/7MAkimrs8UtfOE3nJ0LK')
// .get();

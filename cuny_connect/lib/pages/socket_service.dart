import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuny_connect/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cuny_connect/utils/message.dart';
import 'package:cuny_connect/utils/conversation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  final FirebaseService firebaseService = FirebaseService();
  final String _userID = FirebaseAuth.instance.currentUser!.uid;

  SocketService() {
    _connectToServer();
  }

  IO.Socket get socket => _socket!;

  void _connectToServer() {
    _socket = IO.io('https://45-79-155-215.ip.linodeusercontent.com:3001/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to Socket.IO server');
      _isConnected = true;
      notifyListeners();
    });

    _socket!.on('broadcast', (data) {
      if (data['receiverId'].contains(_userID)) {
        final message = ChatMessage(
          messageId: data['messageId'],
          senderId: data['senderId'],
          receiverId: List<String>.from(data['receiverId']),
          content: data['content'],
          senderName: data['senderName'],
          timestamp: DateTime.parse(data['timestamp']),
          conversationId: data['conversationId'],
        );
        _saveMessage(message);
      }
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
      _isConnected = false;
      notifyListeners();
    });
  }

  void _saveMessage(ChatMessage message) async {
    final box = await Hive.openBox<ChatMessage>('messages_${message.conversationId}');
    box.add(message);

    // Update the conversation in Hive
    var conversationBox = Hive.box<Conversation>('conversations');
    var conversation = conversationBox.get(message.conversationId);
     if (conversation == null) {     
        // Check if the conversation exists in the user's profile
        bool existsInProfile = await firebaseService.checkConversationInUserProfile(message.conversationId);
        if (!existsInProfile) {
          await firebaseService.addConversationToUserProfile(message.conversationId);
        }
        conversationBox.put(message.conversationId, conversation!);
    } else {
      conversation.messages.add(message);
      conversationBox.put(message.conversationId, conversation);
      print('Updated conversation in Hive');
    }

    // Notify listeners to update the UI
    notifyListeners();
  }

  void sendMessage(String conversationId, String content, List<String> receiverNames, String senderName) async {
    if (_socket != null && _isConnected) {
      final messageId = UniqueKey().toString();
      final senderId = _userID;
      final List<String> receiverIds = List.from(receiverNames);
      if (!receiverIds.contains(senderId)) {
        receiverIds.add(senderId);
      }
      receiverIds.removeWhere((id) => id == senderId);

      final message = ChatMessage(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverIds,
        content: content,
        senderName: senderName,
        timestamp: DateTime.now(),
        conversationId: conversationId,
      );

      await FirebaseFirestore.instance.collection('Conversations').doc(conversationId).collection('messages').doc(messageId).set({
        'senderId': senderId,
        'receiverId': receiverIds,
        'content': content,
        'senderName': senderName,
        'timestamp': message.timestamp,
        'conversationId': conversationId,
      });

      final box = Hive.box<ChatMessage>('messages_$conversationId');
      box.add(message);

      _socket!.emit('msg', {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverIds,
        'content': content,
        'senderName': senderName,
        'timestamp': message.timestamp.toIso8601String(),
        'conversationId': conversationId,
      });

      // Update the conversation in Hive
      var conversationBox = Hive.box<Conversation>('conversations');
      var conversation = conversationBox.get(conversationId);
      if (conversation != null) {
        conversation.messages.add(message);
        conversationBox.put(conversationId, conversation);
        print('Updated conversation in Hive after sending message');
      }

      // Notify listeners to update the UI
      notifyListeners();
    }
  }
  
  Future<void> handleLogout() async {
    await _clearHiveBoxes();
    notifyListeners();
  }

  Future<void> handleLogin() async {
    await _loadHiveBoxes();
    notifyListeners();
  }

  Future<void> _clearHiveBoxes() async {
    await Hive.box<Conversation>('conversations').clear();
    // Clear all individual message boxes for each conversation
    var messageBoxes = await Hive.openBox('hive_boxes');
    for (var boxName in messageBoxes.keys) {
      if (boxName.startsWith('messages_')) {
        await Hive.box(boxName).clear();
      }
    }
  }

  Future<void> _loadHiveBoxes() async {
    // Load conversations and messages from Firebase to Hive
    var conversations = await firebaseService.fetchConversations();
    var conversationBox = Hive.box<Conversation>('conversations');
    for (var conversation in conversations) {
      await conversationBox.put(conversation.conversationIds, conversation);
      await Hive.openBox<ChatMessage>('messages_${conversation.conversationIds}');
    }
  }
}

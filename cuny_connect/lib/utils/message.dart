import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String messageId;
  @HiveField(1)
  String senderId;
  @HiveField(2)
  List<String> receiverId;
  @HiveField(3)
  String content;
  @HiveField(4)
  DateTime timestamp;
  @HiveField(5)
  String senderName;

  ChatMessage({required this.messageId, required this.senderId, required this.receiverId, required this.content, required this.timestamp, required this.senderName});

  factory ChatMessage.fromFirestore(Map<String, dynamic> firestoreData, String id) {
    return ChatMessage(
      messageId: id,
      senderId: firestoreData['senderId'],
      receiverId: List<String>.from(firestoreData['receiverId']),
      content: firestoreData['content'],
      senderName: firestoreData['senderName'],
      timestamp: firestoreData['timestamp'].toDate(),
    );
  }
}


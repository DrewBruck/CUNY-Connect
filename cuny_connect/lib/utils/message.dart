import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String messageId;

  @HiveField(1)
  String senderId;

  @HiveField(2)
  String receiverId;

  @HiveField(3)
  String content;

  @HiveField(4)
  DateTime timestamp;

  ChatMessage({required this.messageId, required this.senderId, required this.receiverId, required this.content, required this.timestamp});

}

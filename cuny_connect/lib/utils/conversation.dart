import 'package:hive/hive.dart';
import 'package:cuny_connect/utils/message.dart';

part 'conversation.g.dart';

@HiveType(typeId: 2)
class Conversation extends HiveObject {
  @HiveField(0)
  String conversationId;

  @HiveField(1)
  List<ChatMessage> messages;

  Conversation({required this.conversationId, required this.messages});
}


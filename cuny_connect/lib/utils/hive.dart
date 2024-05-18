import 'package:hive_flutter/hive_flutter.dart';
import 'package:cuny_connect/utils/message.dart';
import 'package:cuny_connect/utils/conversation.dart';

class HiveHelper {
    static bool _isAdapterRegistered = false;

    static Future<void> initializeHive() async {
        await Hive.initFlutter();

        if (!_isAdapterRegistered) {
            Hive.registerAdapter(ChatMessageAdapter());
            Hive.registerAdapter(ConversationAdapter());
            _isAdapterRegistered = true;
        }

        await Hive.openBox<ChatMessage>('messages');
        await Hive.openBox<Conversation>('conversations');
    }
}

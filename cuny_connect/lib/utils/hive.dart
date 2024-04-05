import 'package:hive_flutter/hive_flutter.dart';
import 'package:cuny_connect/utils/message.dart';

class HiveHelper{
  static bool _isAdapterRegistered = false;

  static Future<void> initializedHive() async{
    await Hive.initFlutter();

    if(!_isAdapterRegistered){
      Hive.registerAdapter(ChatMessageAdapter());
      _isAdapterRegistered = true;
    }

    await Hive.openBox<ChatMessage>('messages');
  }
}
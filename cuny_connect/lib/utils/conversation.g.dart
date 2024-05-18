// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 2;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      conversationIds: fields[0] as String,
      messages: (fields[1] as List).cast<ChatMessage>(),
      participants: (fields[2] as List).cast<String>(),
      adminTitle: fields[4] as String,
      isAdmin: fields[5] as bool,
    )..lastMessageTime = fields[3] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.conversationIds)
      ..writeByte(1)
      ..write(obj.messages)
      ..writeByte(2)
      ..write(obj.participants)
      ..writeByte(3)
      ..write(obj.lastMessageTime)
      ..writeByte(4)
      ..write(obj.adminTitle)
      ..writeByte(5)
      ..write(obj.isAdmin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

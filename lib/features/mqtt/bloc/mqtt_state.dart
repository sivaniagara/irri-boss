abstract class MqttState {}

class MqttInitial extends MqttState {}

class MqttLoading extends MqttState {}

class MqttConnected extends MqttState {}

class MqttError extends MqttState {
  final String message;
  MqttError(this.message);
}

// Updated state: holds all received messages
class MqttMessagesState extends MqttState {
  final Map<String, List<MqttMessageRecord>> messagesByTopic; // Group by topic for easy access
  MqttMessagesState({Map<String, List<MqttMessageRecord>>? messagesByTopic})
      : messagesByTopic = messagesByTopic ?? {};

  MqttMessagesState copyWith({Map<String, List<MqttMessageRecord>>? messagesByTopic}) {
    return MqttMessagesState(
      messagesByTopic: messagesByTopic ?? this.messagesByTopic,
    );
  }

  // Helper: Get all messages for a topic
  List<MqttMessageRecord> getMessagesForTopic(String topic) {
    return messagesByTopic[topic] ?? [];
  }

  // Helper: Get latest message overall
  MqttMessageRecord? getLatestMessage() {
    if (messagesByTopic.isEmpty) return null;
    final latestTopic = messagesByTopic.keys.last; // Or sort by timestamp
    final messages = messagesByTopic[latestTopic]!;
    return messages.isNotEmpty ? messages.last : null;
  }
}

// Record for each message (immutable)
class MqttMessageRecord {
  final String topic;
  final String message;
  final DateTime timestamp;

  MqttMessageRecord({required this.topic, required this.message})
      : timestamp = DateTime.now();
}
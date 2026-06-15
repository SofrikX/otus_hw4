class ChatThread {
  const ChatThread({
    required this.id,
    required this.companionName,
    required this.petName,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  final String id;
  final String companionName;
  final String petName;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ChatThread copyWith({
    String? id,
    String? companionName,
    String? petName,
    String? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ChatThread(
      id: id ?? this.id,
      companionName: companionName ?? this.companionName,
      petName: petName ?? this.petName,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

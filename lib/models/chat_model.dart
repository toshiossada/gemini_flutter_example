enum MessageActor {
  user('user'),
  gemini('model');

  final String role;

  const MessageActor(this.role);
}

class ChatModel {
  final String message;
  final MessageActor actor;

  ChatModel({required this.message, required this.actor});
}

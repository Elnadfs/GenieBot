import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> sessions = [];
  int currentSessionIndex = 0;

  void newChat() {
    sessions.add(ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messages: [],
      title: "New Chat ${sessions.length + 1}",
    ));
    currentSessionIndex = sessions.length - 1;
    notifyListeners();
  }

  void selectSession(int index) {
    currentSessionIndex = index;
    notifyListeners();
  }

  void updateSessionMessages(List<ChatMessage> messages) {
    if (sessions.isEmpty) {
      newChat();
    }
    sessions[currentSessionIndex].messages = messages;
    // Update title based on first message if exists
    if (messages.isNotEmpty && sessions[currentSessionIndex].title.startsWith("New Chat")) {
      sessions[currentSessionIndex].title = messages.first.text.length > 30 
          ? "${messages.first.text.substring(0, 30)}..."
          : messages.first.text;
    }
    notifyListeners();
  }
}

class ChatSession {
  final String id;
  List<ChatMessage> messages;
  String title;

  ChatSession({
    required this.id,
    required this.messages,
    required this.title,
  });
} 
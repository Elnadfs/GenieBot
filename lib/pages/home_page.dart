import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gemini_chat_app_tutorial/providers/theme_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gemini_chat_app_tutorial/providers/chat_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(
    id: "0", 
    firstName: "User",
  );
  
  ChatUser genieUser = ChatUser(
    id: "1",
    firstName: "Genie",
  );

  final List<List<Color>> gradientSets = [
    [const Color(0xFF6C63FF), const Color(0xFF4CAF50)],  // Purple to Green
    [const Color(0xFFFF6B6B), const Color(0xFF4ECDC4)],  // Red to Turquoise
    [const Color(0xFFFFBE0B), const Color(0xFFFF006E)],  // Yellow to Pink
    [const Color(0xFF08D9D6), const Color(0xFF252A34)],  // Cyan to Dark
    [const Color(0xFFFF9A8B), const Color(0xFFFF6A88)],  // Peach to Pink
  ];
  late final List<Color> currentGradient;

  @override
  void initState() {
    super.initState();
    currentGradient = gradientSets[DateTime.now().microsecond % gradientSets.length];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).newChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Genie Bot",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.add, color: isDark ? Colors.white : Colors.black87),
                title: Text(
                  "New Chat",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                onTap: () {
                  chatProvider.newChat();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: chatProvider.sessions.length,
                  itemBuilder: (context, index) {
                    final session = chatProvider.sessions[index];
                    return ListTile(
                      leading: Icon(
                        Icons.chat_bubble_outline,
                        color: chatProvider.currentSessionIndex == index
                            ? currentGradient[0]
                            : (isDark ? Colors.white54 : Colors.black54),
                      ),
                      title: Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: chatProvider.currentSessionIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: chatProvider.currentSessionIndex == index,
                      selectedTileColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      onTap: () {
                        chatProvider.selectSession(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : currentGradient[0],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_fix_high,
                color: isDark ? Colors.grey[400] : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Genie Bot",
                  style: TextStyle(
                    color: isDark ? Colors.grey[200] : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Your Magical Assistant",
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentGradient[0].withOpacity(isDark ? 0.1 : 0.2),
              currentGradient[1].withOpacity(isDark ? 0.05 : 0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            if (chatProvider.sessions.isEmpty || 
                chatProvider.sessions[chatProvider.currentSessionIndex].messages.isEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_fix_high,
                        color: Color(0xFF6C63FF),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Welcome to Genie Bot!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ask me anything, and I'll help you with my magical powers! ✨",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Try asking:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildSuggestionChip("What is Flutter?"),
                        _buildSuggestionChip("Tell me a joke"),
                        _buildSuggestionChip("Write a poem about coding"),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Chat Area
            Expanded(
              child: DashChat(
                currentUser: currentUser,
                messages: chatProvider.sessions.isEmpty ? [] 
                    : chatProvider.sessions[chatProvider.currentSessionIndex].messages,
                onSend: _sendMessage,
                messageOptions: MessageOptions(
                  currentUserContainerColor: currentGradient[0],
                  containerColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                  textColor: isDark ? Colors.white : Colors.black87,
                  messagePadding: const EdgeInsets.all(12),
                  borderRadius: 16.0,
                  messageTextBuilder: (message, previousMessage, nextMessage) {
                    if (message.user.id == genieUser.id) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                            code: TextStyle(
                              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            blockquote: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                            h1: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return Text(
                      message.text,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                inputOptions: InputOptions(
                  inputDecoration: InputDecoration(
                    hintText: "Ask your question...",
                    hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  trailing: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: _sendMediaMessage,
                        icon: const Icon(
                          Icons.image,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ],
                ),
                messageListOptions: MessageListOptions(
                  showDateSeparator: true,
                  dateSeparatorFormat: DateFormat("EEEE, MMM d"),
                  dateSeparatorBuilder: (date) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      date.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    List<ChatMessage> currentMessages = chatProvider.sessions.isEmpty ? [] 
        : List.from(chatProvider.sessions[chatProvider.currentSessionIndex].messages);
    
    currentMessages.insert(0, chatMessage);
    chatProvider.updateSessionMessages(currentMessages);

    try {
      String question = chatMessage.text;
      String fullResponse = '';
      
      await for (final event in gemini.promptStream(parts: [TextPart(question)])) {
        String response = event?.output ?? '';
        if (response.contains('```')) {
          response = response.replaceAllMapped(
            RegExp(r'```([^`]+)```'),
            (match) => '\n```\n${match.group(1)?.trim()}\n```\n'
          );
        }
        fullResponse += response;

        List<ChatMessage> updatedMessages = List.from(currentMessages);
        if (updatedMessages.length > 1 && updatedMessages[0].user == genieUser) {
          updatedMessages[0] = ChatMessage(
            user: genieUser,
            createdAt: DateTime.now(),
            text: fullResponse,
          );
        } else {
          updatedMessages.insert(0, ChatMessage(
            user: genieUser,
            createdAt: DateTime.now(),
            text: fullResponse,
          ));
        }
        chatProvider.updateSessionMessages(updatedMessages);
      }
    } catch (e) {
      debugPrint('Error in _sendMessage: $e');
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }

  Widget _buildSuggestionChip(String suggestion) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return ActionChip(
      label: Text(
        suggestion,
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.white,
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : currentGradient[0],
      onPressed: () {
        _sendMessage(
          ChatMessage(
            text: suggestion,
            user: currentUser,
            createdAt: DateTime.now(),
          ),
        );
      },
    );
  }
}

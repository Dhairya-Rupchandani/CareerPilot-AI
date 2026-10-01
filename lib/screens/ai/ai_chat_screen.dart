import 'package:flutter/material.dart';

import '../../services/ai_service.dart';
import '../../services/firestore_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController controller = TextEditingController();

  final AIService ai = AIService();
  final FirestoreService firestore = FirestoreService();

  bool loading = false;

  final List<Map<String, String>> messages = [
    {
      "role": "ai",
      "text":
      "👋 Welcome!\n\nAsk me about careers, Flutter, AI, colleges, interview preparation or study roadmaps."
    }
  ];

  Future<void> sendMessage() async {
    final question = controller.text.trim();

    if (question.isEmpty || loading) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": question,
      });
      loading = true;
    });

    controller.clear();

    // Save chat count in Firebase
    await firestore.incrementChat();

    final reply = await ai.askCareerAI(question);

    if (!mounted) return;

    setState(() {
      messages.add({
        "role": "ai",
        "text": reply,
      });
      loading = false;
    });
  }

  Widget bubble(String role, String text) {
    final isUser = role == "user";

    return Align(
      alignment:
      isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.deepPurpleAccent
              : const Color(0xFF171F35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("CareerPilot AI"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return bubble(msg["role"]!, msg["text"]!);
              },
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "CareerPilot AI is typing...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

          Container(
            color: const Color(0xFF131A2D),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask your career question...",
                      hintStyle:
                      const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF171F35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: IconButton(
                    onPressed: loading ? null : sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/services/api_service.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'content': 'Hi! I am your Aquarium Assistant. Ask me about fish care, water quality, tank cycling, or low-light plants.'
    }
  ];
  
  bool _loading = false;

  final List<String> _suggestions = [
    "What fish can I keep with a Betta?",
    "How do I cycle a new aquarium?",
    "Why is my fish not eating?",
    "Best plants for low light?"
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getLocalBotReply(String prompt) {
    final clean = prompt.toLowerCase();
    if (clean.contains('betta')) {
      return '🐠 **Betta Fish Care**:\nBettas require a minimum of 5 gallons, a heater (75-80°F), and a gentle filter. Do not house males together. Snails or Ghost Shrimp make great tank mates!';
    } else if (clean.contains('cycle') || clean.contains('cycling')) {
      return '🔄 **Aquarium Cycling**:\nCycling builds beneficial bacteria to convert toxic ammonia into safe nitrate. Add an ammonia source and perform daily tests. This process takes 4-6 weeks.';
    } else if (clean.contains('eat') || clean.contains('eating') || clean.contains('food')) {
      return '🍽️ **Feeding & Appetite**:\nIf your fish is not eating, check water parameters (ammonia, nitrite, pH) and temperature immediately. Avoid overfeeding, which degrades water quality.';
    } else if (clean.contains('plant') || clean.contains('light')) {
      return '🌿 **Low-Light Plants**:\nAnubias, Java Fern, Java Moss, and Cryptocoryne are excellent choices. They grow well in standard aquarium lighting and do not require CO2 injection.';
    } else if (clean.contains('water') || clean.contains('parameter') || clean.contains('chemistry')) {
      return '🧪 **Water Parameters**:\nAim for:\n- Ammonia & Nitrite: 0 ppm\n- Nitrate: < 20 ppm\n- pH: 6.8 - 7.6 (for most tropical species)\nPerform weekly 20% water changes.';
    } else if (clean.contains('identify') || clean.contains('species')) {
      return '🔍 **Fish Identification**:\nPlease describe your fish (color, body shape, tail size, markings) and I will do my best to help you identify the species!';
    }
    return '🌊 **AquaBot Expert Tip**:\nRemember to test your aquarium water weekly, perform regular partial water changes, and quarantine new fish before adding them to your main display tank. How else can I assist your aquatic journey today?';
  }

  Future<void> _sendMessage(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': prompt});
      _loading = true;
    });
    _scrollToBottom();

    try {
      final res = await ApiService.post('/api/ai/chat', {
        'messages': _messages,
      });

      if (res.statusCode == 200) {
        String reply = res.body;
        try {
          final data = jsonDecode(res.body);
          reply = data['message'] ?? data['reply'] ?? data['data'] ?? res.body;
        } catch (_) {}

        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
          _loading = false;
        });
      } else {
        // Fallback to local bot reply on non-200 responses
        throw Exception();
      }
    } catch (_) {
      // Direct local chatbot response
      await Future.delayed(const Duration(milliseconds: 600));
      final reply = _getLocalBotReply(prompt);
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AI Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final content = msg['content'] ?? '';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF00B4D8) : const Color(0xFF112240),
                      borderRadius: BorderRadius.circular(16),
                      border: isUser ? null : Border.all(color: const Color(0xFF1E3A5C)),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          const Icon(Icons.smart_toy_outlined, color: Color(0xFF00B4D8), size: 18),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            content,
                            style: TextStyle(color: isUser ? Colors.white : const Color(0xFF7AB8CC), fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))),
            ),
          
          // Suggestion chips (only shown when chat is starting / few messages)
          if (_messages.length <= 2)
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(_suggestions[idx], style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 12)),
                      backgroundColor: const Color(0xFF112240),
                      side: const BorderSide(color: Color(0xFF1E3A5C)),
                      onPressed: () => _sendMessage(_suggestions[idx]),
                    ),
                  );
                },
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1F35),
              border: Border(top: BorderSide(color: Color(0xFF1E3A5C))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ask your aquarium question...',
                      hintStyle: TextStyle(color: Color(0xFF4A6B82)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00B4D8)),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

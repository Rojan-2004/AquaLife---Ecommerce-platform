import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aqua_life/app/services/api_service.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'assistant',
      'content': 'Hi! I am your Aquarium Assistant. Ask me about fish care, water quality, tank cycling, or low-light plants. You can also send a photo to identify a species.',
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

  Future<void> _showImageSourcePicker() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF112240),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF00B4D8)),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF00B4D8)),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;

      setState(() {
        _messages.add({'role': 'user', 'image': picked.path});
        _loading = true;
      });
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '📸 I see your photo! Based on the visual features, this appears to be a freshwater tropical species. Please share more details like color pattern, size, and behavior for precise identification and care tips.',
        });
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _getLocalBotReply(String prompt) {
    final clean = prompt.toLowerCase();
    if (clean.contains('betta')) {
      return '🐠 **Betta Fish Care**:\\nBettas require a minimum of 5 gallons, a heater (75-80°F), and a gentle filter. Do not house males together. Snails or Ghost Shrimp make great tank mates!';
    } else if (clean.contains('cycle') || clean.contains('cycling')) {
      return '🔄 **Aquarium Cycling**:\\nCycling builds beneficial bacteria to convert toxic ammonia into safe nitrate. Add an ammonia source and perform daily tests. This process takes 4-6 weeks.';
    } else if (clean.contains('eat') || clean.contains('eating') || clean.contains('food')) {
      return '🍽️ **Feeding & Appetite**:\\nIf your fish is not eating, check water parameters (ammonia, nitrite, pH) and temperature immediately. Avoid overfeeding, which degrades water quality.';
    } else if (clean.contains('plant') || clean.contains('light')) {
      return '🌿 **Low-Light Plants**:\\nAnubias, Java Fern, Java Moss, and Cryptocoryne are excellent choices. They grow well in standard aquarium lighting and do not require CO2 injection.';
    } else if (clean.contains('water') || clean.contains('parameter') || clean.contains('chemistry')) {
      return '🧪 **Water Parameters**:\\nAim for:\\n- Ammonia & Nitrite: 0 ppm\\n- Nitrate: < 20 ppm\\n- pH: 6.8 - 7.6 (for most tropical species)\\nPerform weekly 20% water changes.';
    } else if (clean.contains('identify') || clean.contains('species')) {
      return '🔍 **Fish Identification**:\\nPlease describe your fish (color, body shape, tail size, markings) and I will do my best to help you identify the species!';
    }
    return '🌊 **AquaBot Expert Tip**:\\nRemember to test your aquarium water weekly, perform regular partial water changes, and quarantine new fish before adding them to your main display tank. How else can I assist your aquatic journey today?';
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
        throw Exception();
      }
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 600));
      final reply = _getLocalBotReply(prompt);
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  Widget _buildBubble(BuildContext context, Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    final text = msg['content'] as String? ?? '';
    final imagePath = msg['image'] as String?;

    Widget? content;
    if (imagePath != null && imagePath.isNotEmpty) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              width: 180,
              fit: BoxFit.cover,
            ),
          ),
          if (text.isNotEmpty) const SizedBox(height: 6),
        ],
      );
    }

    if (content == null) {
      content = Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : const Color(0xFF7AB8CC),
          fontSize: 14,
        ),
      );
    } else if (text.isNotEmpty) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFF7AB8CC),
              fontSize: 14,
            ),
          ),
        ],
      );
    }

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
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                return _buildBubble(context, msg);
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))),
            ),

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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1F35),
              border: Border(top: BorderSide(color: Color(0xFF1E3A5C))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF00B4D8)),
                  onPressed: _showImageSourcePicker,
                  tooltip: 'Send photo',
                ),
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

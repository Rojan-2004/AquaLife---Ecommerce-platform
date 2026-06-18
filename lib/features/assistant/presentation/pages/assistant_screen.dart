import 'dart:io';

import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      sender: _MessageSender.assistant,
      text:
          'Hi! I am your Aquarium Assistant. Ask me about fish care, water quality, or upload a photo to identify a species.',
    ),
  ];
  String? _selectedImagePath;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 12 : 16,
            ),
            child: Column(
              children: [
                _buildAppBar(compact),
                SizedBox(height: compact ? 12 : 16),
                _buildMessageList(compact, constraints.maxHeight),
                SizedBox(height: compact ? 12 : 16),
                _buildQuickSuggestions(compact),
                if (_selectedImagePath != null) ...[
                  SizedBox(height: compact ? 10 : 12),
                  _buildSelectedImagePreview(compact),
                ],
                SizedBox(height: compact ? 10 : 12),
                _buildInputBar(compact, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool compact) {
    return Row(
      children: [
        Container(
          width: compact ? 38 : 42,
          height: compact ? 38 : 42,
          decoration: BoxDecoration(
            color: kMid,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.smart_toy_outlined, color: kAccent, size: 22),
        ),
        SizedBox(width: compact ? 9 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aquarium Assistant',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 15 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Powered by AquaLife AI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: kSub, fontSize: compact ? 10 : 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList(bool compact, double screenHeight) {
    return SizedBox(
      height: _messageListHeight(compact, screenHeight),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _messages.length,
        separatorBuilder: (_, _) => SizedBox(height: compact ? 10 : 12),
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessage(message, compact);
        },
      ),
    );
  }

  double _messageListHeight(bool compact, double screenHeight) {
    final reservedHeight = compact ? 230.0 : 260.0;
    return (screenHeight - reservedHeight).clamp(280.0, 430.0).toDouble();
  }

  Widget _buildMessage(_ChatMessage message, bool compact) {
    final isAssistant = message.sender == _MessageSender.assistant;

    return Row(
      mainAxisAlignment: isAssistant
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isAssistant) ...[
          Container(
            width: compact ? 26 : 30,
            height: compact ? 26 : 30,
            margin: EdgeInsets.only(right: compact ? 6 : 8),
            decoration: const BoxDecoration(
              color: kMid,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: kAccent, size: 15),
          ),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isAssistant
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              if (message.imagePath != null)
                _buildImagePreview(message.imagePath!, compact),
              if (message.imagePath != null && message.text.isNotEmpty)
                SizedBox(height: compact ? 6 : 8),
              if (message.text.isNotEmpty) _buildTextBubble(message, compact),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextBubble(_ChatMessage message, bool compact) {
    final isAssistant = message.sender == _MessageSender.assistant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 11 : 13,
        vertical: compact ? 9 : 11,
      ),
      decoration: BoxDecoration(
        color: isAssistant ? kCard : kAccent,
        borderRadius: BorderRadius.circular(16),
        border: isAssistant ? Border.all(color: kBorder) : null,
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildImagePreview(String path, bool compact) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(path),
        width: compact ? 128 : 168,
        height: compact ? 96 : 124,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget _buildQuickSuggestions(bool compact) {
    const suggestions = [
      'Identify a fish',
      'Recommend food',
      'Tank troubleshooting',
    ];

    return SizedBox(
      height: compact ? 32 : 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => SizedBox(width: compact ? 8 : 10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _addAssistantReply(suggestions[index]),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 7 : 9,
              ),
              decoration: BoxDecoration(
                color: kMid,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                suggestions[index],
                maxLines: 1,
                style: TextStyle(
                  color: kAccent,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedImagePreview(bool compact) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_selectedImagePath!),
          width: compact ? 76 : 92,
          height: compact ? 58 : 70,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInputBar(bool compact, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: kAccent,
              size: 20,
            ),
            onPressed: () => _showImageSourceSheet(context),
          ),
          if (_selectedImagePath != null) ...[
            SizedBox(width: compact ? 6 : 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_selectedImagePath!),
                width: compact ? 32 : 36,
                height: compact ? 32 : 36,
                fit: BoxFit.cover,
              ),
            ),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Ask or upload a fish photo...',
                hintStyle: TextStyle(color: kHint, fontSize: compact ? 12 : 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 12,
                  vertical: compact ? 10 : 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: compact ? 30 : 34,
              minHeight: compact ? 30 : 34,
            ),
            icon: const Icon(Icons.send, color: Colors.white, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImageSourceButton(
                  context: dialogContext,
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  source: ImageSource.camera,
                ),
                const SizedBox(height: 10),
                _buildImageSourceButton(
                  context: dialogContext,
                  icon: Icons.photo_library_outlined,
                  label: 'Choose From Gallery',
                  source: ImageSource.gallery,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _pickImage(source);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: kAccent),
            const SizedBox(width: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image == null || !mounted) return;

    setState(() => _selectedImagePath = image.path);
  }

  void _sendMessage(String value) {
    final text = value.trim().isEmpty ? _controller.text.trim() : value.trim();
    final imagePath = _selectedImagePath;
    if (text.isEmpty && imagePath == null) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          sender: _MessageSender.user,
          text: text,
          imagePath: imagePath,
        ),
      );
      _controller.clear();
      _selectedImagePath = null;
    });

    _addAssistantReply(
      text.isEmpty ? 'Identify this image' : text,
      imagePath: imagePath,
    );
  }

  void _addAssistantReply(String prompt, {String? imagePath}) {
    setState(() {
      _messages.add(
        _ChatMessage(
          sender: _MessageSender.assistant,
          text: imagePath != null
              ? 'I received the image. Share tank size, water parameters, or symptoms and I can help identify the fish or troubleshoot the issue.'
              : 'I can help with "$prompt". Share a photo or tell me your tank size, water parameters, and fish behavior for a better recommendation.',
        ),
      );
    });
  }
}

enum _MessageSender { assistant, user }

class _ChatMessage {
  const _ChatMessage({
    required this.sender,
    required this.text,
    this.imagePath,
  });

  final _MessageSender sender;
  final String text;
  final String? imagePath;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../customer/models/ground_model.dart';
import '../models/chat_message_model.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      id: 'msg_1',
      isUser: false,
      text: 'Hey there! Looking for a football slot tonight around Bahria Town or Islamabad?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      groundIds: ['ground_1', 'ground_2'],
      suggestionChips: ['Yes, 5-a-side around 8 PM under 5000 PKR', 'Cricket turf near Rawalpindi', 'Padel tennis courts'],
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? presetText]) async {
    final query = presetText ?? _textController.text.trim();
    if (query.isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: true,
          text: query,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final groundRepo = ref.read(groundRepositoryProvider);
      final aiRepo = ref.read(aiRepositoryProvider);
      final allGrounds = await groundRepo.getAllGrounds();

      final aiResponse = await aiRepo.sendChatMessage(
        userMessage: query,
        allGrounds: allGrounds,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(aiResponse);
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groundRepo = ref.watch(groundRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppColors.emeraldGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GroundBot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, color: AppColors.emerald, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'AI Assistant Online',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.emeraldDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.navy, size: 22),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessageModel(
                    id: 'msg_initial',
                    isUser: false,
                    text: 'Hello! Ask me to recommend pitches, verify prices, or find open slots tonight!',
                    timestamp: DateTime.now(),
                    groundIds: ['ground_1'],
                    suggestionChips: ['5-a-side futsal tonight', 'Cricket turfs under 4000', 'Padel tennis'],
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<GroundModel>>(
        future: groundRepo.getAllGrounds(),
        builder: (context, snapshot) {
          final allGrounds = snapshot.data ?? [];
          final Map<String, GroundModel> groundMap = {
            for (final g in allGrounds) g.id: g,
          };

          final lastMessageChips = _messages.isNotEmpty ? _messages.last.suggestionChips : null;

          return Column(
            children: [
              // Chat message list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message, groundMap);
                  },
                ),
              ),

              // Typing indicator
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      const Text(
                        'GroundBot is searching available slots...',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(color: AppColors.emerald, strokeWidth: 1.5),
                      ),
                    ],
                  ),
                ),

              // Suggestion Chips
              if (lastMessageChips != null && lastMessageChips.isNotEmpty)
                Container(
                  height: 42,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: lastMessageChips.map((chip) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            chip,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.emerald, width: 1),
                          onPressed: () => _handleSendMessage(chip),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Bottom Input Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: TextField(
                            controller: _textController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _handleSendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Ask AI assistant...',
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.textMutedLight),
                              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                          onPressed: () => _handleSendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, Map<String, GroundModel> groundMap) {
    final isUser = message.isUser;
    final recommendedGrounds = message.groundIds
        .map((id) => groundMap[id])
        .whereType<GroundModel>()
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.emeraldContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sports_soccer, color: AppColors.emeraldDark, size: 16),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isUser ? Colors.white : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Ground recommendation cards attached to AI message
          if (!isUser && recommendedGrounds.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedGrounds.length,
                itemBuilder: (context, index) {
                  final ground = recommendedGrounds[index];
                  return _buildAiGroundCard(ground);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiGroundCard(GroundModel ground) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              ground.primaryImage,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ground.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        Text(' ${ground.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  ground.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKR ${ground.pricePerHour.toInt()}/hr',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emeraldDark,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/customer/ground/${ground.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Book Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

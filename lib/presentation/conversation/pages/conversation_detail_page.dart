import 'dart:math';
import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/presentation/conversation/widgets/message.dart';

import '../../../core/configs/theme/index.dart';

class ConversationDetailPage extends StatefulWidget {
  const ConversationDetailPage({super.key});

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final List<LinearGradient> _backgroundGradients = [
    LinearGradient(
      colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4E342E), Color(0xFF004D40)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    LinearGradient(
      colors: [Color(0xFF3E2723), Color(0xFF1C1C1C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF000000)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF37474F), Color(0xFF212121)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF1B1B1B)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ];

  LinearGradient _currentBackgroundGradient = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  double _lastScrollPosition = 0;

  // Sample conversation data
  List<Map<String, dynamic>> get _conversationData => [
    {
      'message': 'Hey! How are you doing today?',
      'isMe': false,
      'timestamp': '10:30 AM',
    },
    {
      'message': 'I\'m doing great! Just finished my morning workout.',
      'isMe': true,
      'timestamp': '10:32 AM',
    },
    {
      'message': 'That sounds awesome! What exercises did you do?',
      'isMe': false,
      'timestamp': '10:33 AM',
    },
    {
      'message': 'Mostly cardio and some strength training. How about you?',
      'isMe': true,
      'timestamp': '10:35 AM',
    },
    {
      'message': 'I\'m planning to go for a run later. Want to join?',
      'isMe': false,
      'timestamp': '10:36 AM',
    },
    {
      'message': 'Sure! That would be fun. What time works for you?',
      'isMe': true,
      'timestamp': '10:38 AM',
    },
    {
      'message': 'How about 6 PM? We can meet at the park.',
      'isMe': false,
      'timestamp': '10:40 AM',
    },
    {
      'message': 'Perfect! See you there at 6 PM.',
      'isMe': true,
      'timestamp': '10:41 AM',
    },
    {
      'message': 'Great! I\'ll bring some water and snacks.',
      'isMe': false,
      'timestamp': '10:42 AM',
    },
    {
      'message': 'That\'s thoughtful! I\'ll bring my running shoes.',
      'isMe': true,
      'timestamp': '10:43 AM',
    },
    {
      'message': 'Should we do a 5K or just a casual run?',
      'isMe': false,
      'timestamp': '10:44 AM',
    },
    {
      'message': 'Let\'s start with a casual run and see how we feel.',
      'isMe': true,
      'timestamp': '10:45 AM',
    },
    {
      'message': 'Perfect! I\'m excited to catch up while we run.',
      'isMe': false,
      'timestamp': '10:46 AM',
    },
    {
      'message': 'Me too! It\'s been a while since we\'ve hung out.',
      'isMe': true,
      'timestamp': '10:47 AM',
    },
    {
      'message': 'Exactly! This will be a great way to stay active and social.',
      'isMe': false,
      'timestamp': '10:48 AM',
    },
    {
      'message': 'How about 6 PM? We can meet at the park.',
      'isMe': false,
      'timestamp': '10:40 AM',
    },
    {
      'message': 'Perfect! See you there at 6 PM.',
      'isMe': true,
      'timestamp': '10:41 AM',
    },
    {
      'message': 'Great! I\'ll bring some water and snacks.',
      'isMe': false,
      'timestamp': '10:42 AM',
    },
    {
      'message': 'That\'s thoughtful! I\'ll bring my running shoes.',
      'isMe': true,
      'timestamp': '10:43 AM',
    },
    {
      'message': 'Should we do a 5K or just a casual run?',
      'isMe': false,
      'timestamp': '10:44 AM',
    },
    {
      'message': 'Let\'s start with a casual run and see how we feel.',
      'isMe': true,
      'timestamp': '10:45 AM',
    },
    {
      'message': 'Perfect! I\'m excited to catch up while we run.',
      'isMe': false,
      'timestamp': '10:46 AM',
    },
    {
      'message': 'Me too! It\'s been a while since we\'ve hung out.',
      'isMe': true,
      'timestamp': '10:47 AM',
    },
    {
      'message': 'Exactly! This will be a great way to stay active and social.',
      'isMe': false,
      'timestamp': '10:48 AM',
    },
    {
      'message': 'How about 6 PM? We can meet at the park.',
      'isMe': false,
      'timestamp': '10:40 AM',
    },
    {
      'message': 'Perfect! See you there at 6 PM.',
      'isMe': true,
      'timestamp': '10:41 AM',
    },
    {
      'message': 'Great! I\'ll bring some water and snacks.',
      'isMe': false,
      'timestamp': '10:42 AM',
    },
    {
      'message': 'That\'s thoughtful! I\'ll bring my running shoes.',
      'isMe': true,
      'timestamp': '10:43 AM',
    },
    {
      'message': 'Should we do a 5K or just a casual run?',
      'isMe': false,
      'timestamp': '10:44 AM',
    },
    {
      'message': 'Let\'s start with a casual run and see how we feel.',
      'isMe': true,
      'timestamp': '10:45 AM',
    },
    {
      'message': 'Perfect! I\'m excited to catch up while we run.',
      'isMe': false,
      'timestamp': '10:46 AM',
    },
    {
      'message': 'Me too! It\'s been a while since we\'ve hung out.',
      'isMe': true,
      'timestamp': '10:47 AM',
    },
    {
      'message': 'Exactly! This will be a great way to stay active and social.',
      'isMe': false,
      'timestamp': '10:48 AM',
    },
    {
      'message': 'How about 6 PM? We can meet at the park.',
      'isMe': false,
      'timestamp': '10:40 AM',
    },
    {
      'message': 'Perfect! See you there at 6 PM.',
      'isMe': true,
      'timestamp': '10:41 AM',
    },
    {
      'message': 'Great! I\'ll bring some water and snacks.',
      'isMe': false,
      'timestamp': '10:42 AM',
    },
    {
      'message': 'That\'s thoughtful! I\'ll bring my running shoes.',
      'isMe': true,
      'timestamp': '10:43 AM',
    },
    {
      'message': 'Should we do a 5K or just a casual run?',
      'isMe': false,
      'timestamp': '10:44 AM',
    },
    {
      'message': 'Let\'s start with a casual run and see how we feel.',
      'isMe': true,
      'timestamp': '10:45 AM',
    },
    {
      'message': 'Perfect! I\'m excited to catch up while we run.',
      'isMe': false,
      'timestamp': '10:46 AM',
    },
    {
      'message': 'Me too! It\'s been a while since we\'ve hung out.',
      'isMe': true,
      'timestamp': '10:47 AM',
    },
    {
      'message': 'Exactly! This will be a great way to stay active and social.',
      'isMe': false,
      'timestamp': '10:48 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentPosition = _scrollController.position.pixels;
    final scrollDelta = (currentPosition - _lastScrollPosition).abs();

    // Change background gradient when scrolling more than 500 pixels
    if (scrollDelta > 800) {
      _changeBackgroundGradient();
      _lastScrollPosition = currentPosition;
    }
  }

  void _changeBackgroundGradient() {
    final random = Random();
    LinearGradient newGradient;
    do {
      newGradient =
          _backgroundGradients[random.nextInt(_backgroundGradients.length)];
    } while (newGradient == _currentBackgroundGradient &&
        _backgroundGradients.length > 1);

    setState(() {
      _currentBackgroundGradient = newGradient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
              size: AppDimensions.avatarMd,
            ),
            const SizedBox(width: AppDimensions.md),
            Text(
              'Name 1123',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        action: Icon(Icons.more_horiz, size: AppDimensions.iconLg),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: _currentBackgroundGradient),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(gradient: _currentBackgroundGradient),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.md,
                    right: AppDimensions.md,
                    top: AppDimensions.lg,
                    bottom: AppDimensions.xxl * 2,
                  ),
                  child: Column(
                    children:
                        _conversationData.map((messageData) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.md,
                            ),
                            child: Message(
                              message: messageData['message'],
                              isMe: messageData['isMe'],
                              timestamp: messageData['timestamp'],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.md,
                    right: AppDimensions.md,
                    top: AppDimensions.lg,
                    bottom: AppDimensions.lg,
                  ),
                  child: MessageField(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

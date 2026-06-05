import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/app/theme/app_colors.dart';
import 'package:aqua_life/features/home/presentation/view_model/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(),
              _buildPostInputSection(),
              _buildStorySection(state.stories),
              ...state.posts.map((post) => _buildFeedPost(
                name: post['name'],
                time: post['time'],
                text: post['text'],
                likes: post['likes'],
                comments: post['comments'],
                hasImage: post['hasImage'],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AquaLife',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.search, size: 28, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.near_me_outlined, size: 28, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostInputSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF112240),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF1A3A5C),
                  child: Icon(Icons.person, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "What's on your head?",
                    style: TextStyle(color: const Color(0xFF7AB8CC).withValues(alpha: 0.8), fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1F35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E3A5C)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPostOption(Icons.image, 'Image', AppColors.primaryBlue),
                  Container(
                    width: 1,
                    height: 20,
                    color: const Color(0xFF1E3A5C),
                  ),
                  _buildPostOption(Icons.videocam, 'Videos', AppColors.primaryBlue),
                  Container(
                    width: 1,
                    height: 20,
                    color: const Color(0xFF1E3A5C),
                  ),
                  _buildPostOption(Icons.auto_awesome, 'AI', AppColors.primaryBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostOption(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF7AB8CC), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStorySection(List<String> stories) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final isAdd = story == 'Add';
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAdd ? AppColors.primaryBlue : const Color(0xFF1E3A5C),
                      width: 1.5,
                    ),
                    color: isAdd
                        ? const Color(0xFF0D1F35)
                        : const Color(0xFF112240),
                  ),
                  child: isAdd
                      ? const Icon(Icons.add, color: AppColors.primaryBlue)
                      : const CircleAvatar(
                          backgroundColor: Color(0xFF1A3A5C),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  story,
                  style: const TextStyle(
                    color: Color(0xFF7AB8CC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedPost({
    required String name,
    required String time,
    required String text,
    required String likes,
    required String comments,
    required bool hasImage,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1E3A5C)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF1A3A5C),
                child: Icon(Icons.person, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF7AB8CC),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
          if (hasImage) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=1000&auto=format&fit=crop',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: const Color(0xFF0D1F35),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, color: Color(0xFF7AB8CC), size: 40),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionIcon(Icons.thumb_up_alt_outlined, likes),
                  const SizedBox(width: 20),
                  _buildActionIcon(Icons.chat_bubble_outline, comments),
                  const SizedBox(width: 20),
                  _buildActionIcon(Icons.reply_outlined, ''),
                ],
              ),
              const Icon(Icons.bookmark_border, color: Color(0xFF7AB8CC)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7AB8CC), size: 22),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(count, style: const TextStyle(color: Color(0xFF7AB8CC))),
        ],
      ],
    );
  }
}

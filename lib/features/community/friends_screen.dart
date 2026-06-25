// lib/features/community/friends_screen.dart - COMPLETE VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pranaverse/presentation/providers/user_provider.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:go_router/go_router.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final List<Map<String, dynamic>> _friends = [
    {
      'id': '1',
      'name': 'Alex Chen',
      'avatar': '👨‍💻',
      'streak': 42,
      'lastActive': '2 hours ago',
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Maya Sharma',
      'avatar': '👩‍🏫',
      'streak': 28,
      'lastActive': 'Online now',
      'isOnline': true,
    },
    {
      'id': '3',
      'name': 'David Wilson',
      'avatar': '👨‍🎨',
      'streak': 15,
      'lastActive': '1 day ago',
      'isOnline': false,
    },
    {
      'id': '4',
      'name': 'Sarah Johnson',
      'avatar': '👩‍⚕️',
      'streak': 36,
      'lastActive': 'Online now',
      'isOnline': true,
    },
    {
      'id': '5',
      'name': 'Ryan Park',
      'avatar': '👨‍🍳',
      'streak': 7,
      'lastActive': '3 days ago',
      'isOnline': false,
    },
    {
      'id': '6',
      'name': 'Priya Patel',
      'avatar': '👩‍🔬',
      'streak': 56,
      'lastActive': 'Online now',
      'isOnline': true,
    },
  ];

  final List<Map<String, dynamic>> _communityChallenges = [
    {
      'id': '1',
      'title': '7-Day Mindfulness Challenge',
      'participants': 142,
      'progress': 75,
      'endDate': 'Ends in 3 days',
    },
    {
      'id': '2',
      'title': 'Morning Meditation Group',
      'participants': 89,
      'progress': 60,
      'endDate': 'Ongoing',
    },
    {
      'id': '3',
      'title': 'Stress Relief Week',
      'participants': 256,
      'progress': 90,
      'endDate': 'Ends tomorrow',
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'user': 'Alex Chen',
      'action': 'completed a 30-minute meditation',
      'time': '2 hours ago',
      'icon': Icons.self_improvement,
    },
    {
      'user': 'Maya Sharma',
      'action': 'reached 28-day streak! 🎉',
      'time': '4 hours ago',
      'icon': Icons.local_fire_department,
    },
    {
      'user': 'Community',
      'action': 'Stress Relief Challenge started',
      'time': '1 day ago',
      'icon': Icons.emoji_events,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community & Friends'),
        backgroundColor: const Color(0xFF0a0a1a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/main'),
        ),
        actions: [
          IconButton(
            onPressed: _addFriend,
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Friend',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0a1a),
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // User stats header
            SliverToBoxAdapter(
              child: _buildUserStats(currentUser),
            ),

            // Friends section header
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: 'Your Friends',
                icon: Icons.people,
                actionText: 'See All',
                onAction: () => _showAllFriends(),
              ),
            ),

            // Friends list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final friend = _friends[index];
                    return _buildFriendCard(friend);
                  },
                  childCount: _friends.length,
                ),
              ),
            ),

            // Community challenges header
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: 'Community Challenges',
                icon: Icons.emoji_events,
                actionText: 'Join More',
                onAction: () => _joinChallenge(),
              ),
            ),

            // Challenges list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final challenge = _communityChallenges[index];
                    return _buildChallengeCard(challenge);
                  },
                  childCount: _communityChallenges.length,
                ),
              ),
            ),

            // Recent activities header
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: 'Recent Activities',
                icon: Icons.history,
              ),
            ),

            // Activities list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final activity = _recentActivities[index];
                    return _buildActivityItem(activity);
                  },
                  childCount: _recentActivities.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(UserModel? user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea).withOpacity(0.3),
            const Color(0xFF764ba2).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // User avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00b4d8), Color(0xFF0077b6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '👤',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Mindful Gardener',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildStatItem(Icons.people, '${_friends.length}', 'Friends'),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.emoji_events, '${_communityChallenges.length}', 'Challenges'),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.trending_up, '${user?.currentStreak ?? 0}', 'Streak'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  color: const Color(0xFF00b4d8),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return GestureDetector(
      onTap: () => _viewFriendProfile(friend),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friend status indicator
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: friend['isOnline']
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      friend['avatar'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                if (friend['isOnline'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              friend['name'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 12,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '${friend['streak']}d',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              friend['lastActive'],
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9d4edd).withOpacity(0.2),
            const Color(0xFF560bad).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                challenge['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00b4d8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  challenge['endDate'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${challenge['participants']} participants',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${challenge['progress']}% complete',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: challenge['progress'] / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: const Color(0xFF00b4d8),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _joinSpecificChallenge(challenge),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00b4d8),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Join Challenge',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity['icon'] as IconData,
              size: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: activity['user'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(
                        text: ' ',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextSpan(
                        text: activity['action'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _reactToActivity(activity),
            icon: const Icon(Icons.favorite_border, size: 20, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Add Friend', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter friend code or username',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share your code: ABCD-1234',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              // Add friend logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend request sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00b4d8),
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _viewFriendProfile(Map<String, dynamic> friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e).withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Text(
                friend['avatar'],
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              friend['name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: friend['isOnline'] ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                friend['isOnline'] ? 'Online' : 'Offline',
                style: TextStyle(
                  color: friend['isOnline'] ? Colors.green : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFriendStats(friend),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _sendMessage(friend),
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00b4d8),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _challengeFriend(friend),
                  icon: const Icon(Icons.emoji_events, size: 18),
                  label: const Text('Challenge'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendStats(Map<String, dynamic> friend) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCircle('${friend['streak']}', 'Day Streak', Icons.local_fire_department),
        _buildStatCircle('30', 'Total Hours', Icons.timer),
        _buildStatCircle('12', 'Meditations', Icons.self_improvement),
      ],
    );
  }

  Widget _buildStatCircle(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.white70),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _sendMessage(Map<String, dynamic> friend) {
    Navigator.of(context).pop(); // Close profile
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Message ${friend['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your message...',
            hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
            filled: true,
            fillColor: const Color(0xFF0D0D1F),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00b4d8)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Message sent to ${friend['name']}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00b4d8),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _challengeFriend(Map<String, dynamic> friend) {
    Navigator.of(context).pop(); // Close profile
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Challenge ${friend['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChallengeOption('🧘 10-min Meditation Challenge', 'Complete 10 minutes of meditation'),
            _buildChallengeOption('🔥 7-Day Streak Challenge', 'Maintain a 7-day meditation streak'),
            _buildChallengeOption('😊 Mood Tracking Challenge', 'Log mood for 5 consecutive days'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeOption(String title, String description) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events, size: 20, color: Colors.white70),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge sent!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _showAllFriends() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e).withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'All Friends',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  return ListTile(
                    leading: Text(
                      friend['avatar'],
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      friend['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      friend['lastActive'],
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${friend['streak']}d',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () => _viewFriendProfile(friend),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinChallenge() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e).withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Join a Challenge',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildChallengeJoinOption(
              '🌱 Beginner Mindfulness',
              'Perfect for newcomers to meditation',
              '2,145 participants',
            ),
            _buildChallengeJoinOption(
              '💪 30-Day Meditation Streak',
              'Commit to daily meditation for a month',
              '845 participants',
            ),
            _buildChallengeJoinOption(
              '😌 Stress Relief Program',
              'Reduce stress with guided exercises',
              '1,523 participants',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Joined challenge successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00b4d8),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Browse All Challenges',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeJoinOption(String title, String description, String participants) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                participants,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Joined challenge!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38b000).withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                ),
                child: const Text('Join', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _joinSpecificChallenge(Map<String, dynamic> challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Join ${challenge['title']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to join this challenge? You\'ll be competing with ${challenge['participants']} other participants.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joined ${challenge['title']}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00b4d8),
            ),
            child: const Text('Join Challenge'),
          ),
        ],
      ),
    );
  }

  void _reactToActivity(Map<String, dynamic> activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reacted to ${activity['user']}\'s activity'),
        backgroundColor: Colors.pink,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}


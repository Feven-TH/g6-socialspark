import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      child: ListView(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,', style: TextStyle(color: Colors.grey)),
                    Text('Abebe Kebede', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search content, templates, etc.',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(icon: Icons.auto_awesome, label: 'Create', onTap: () => context.go('/create')), 
                _QuickActionButton(icon: Icons.schedule, label: 'Scheduler', onTap: () => context.go('/scheduler-board')),
                _QuickActionButton(icon: Icons.analytics_outlined, label: 'Analytics', onTap: () {}),
                _QuickActionButton(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(thickness: 8, color: Color(0xFFF4F4F4)),

          // Upcoming Posts Section
          _buildSectionHeader(context, 'Upcoming Posts', 'View All', () {}),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _UpcomingPostCard(
                  color: Colors.blue.shade100,
                  platformIcon: Icons.facebook, 
                  date: 'NOV 25',
                  time: '09:00 AM',
                  caption: 'Exciting news coming soon! Stay tuned.',
                ),
                _UpcomingPostCard(
                  color: Colors.pink.shade100,
                  platformIcon: Icons.camera_alt, 
                  date: 'NOV 28',
                  time: '01:00 PM',
                  caption: 'Behind the scenes of our new collection.',
                ),
              ],
            ),
          ),

          const Divider(thickness: 8, color: Color(0xFFF4F4F4)),

          // Performance Highlights
          _buildSectionHeader(context, 'Performance Highlights', 'Last 7 days', () {}),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _PerformanceStat(label: 'Impressions', value: '2,345', change: '+15%', isPositive: true),
                const SizedBox(width: 16),
                _PerformanceStat(label: 'Engagement', value: '189', change: '-2.3%', isPositive: false),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Padding _buildSectionHeader(BuildContext context, String title, String actionText, VoidCallback onActionPressed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          TextButton(onPressed: onActionPressed, child: Text(actionText)),
        ],
      ),
    );
  }
}


class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _UpcomingPostCard extends StatelessWidget {
  final Color color;
  final IconData platformIcon;
  final String date;
  final String time;
  final String caption;

  const _UpcomingPostCard({
    required this.color,
    required this.platformIcon,
    required this.date,
    required this.time,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(platformIcon, color: Colors.black54),
              const Spacer(),
              Text('$date - $time', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(caption, maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          const Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.white), 
              SizedBox(width: -8),
              CircleAvatar(radius: 12, backgroundColor: Colors.white70),
            ],
          )
        ],
      ),
    );
  }
}

class _PerformanceStat extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const _PerformanceStat({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                Text(change, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

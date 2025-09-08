import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Demo upcoming posts data
  List<Map<String, Object>> get _upcomingPosts => const [
        {
          'image':
              'https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=800',
          'icon': Icons.facebook,
          'date': 'NOV 25',
          'time': '09:00 AM',
          'caption': 'Exciting news coming soon! Stay tuned.',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=800',
          'icon': Icons.camera_alt_outlined,
          'date': 'NOV 28',
          'time': '01:00 PM',
          'caption': 'Behind the scenes of our new collection.',
        },
        {
          'image':
              'https://images.unsplash.com/photo-1485808191679-5f86510681a2?q=80&w=800',
          'icon': Icons.ondemand_video_outlined,
          'date': 'DEC 01',
          'time': '06:30 PM',
          'caption': 'Holiday teaser video drops soon 🎥',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      child: Container(
        // 👇 Soft, app-wide gradient background (not white)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4F0FF), // lilac tint
              Color(0xFFFFF5D6), // warm cream
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=300',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: TextStyle(color: Colors.grey)),
                          // (Add user name here if you have it in state)
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search content, templates, etc.',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    // let gradient peek through a bit
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuickActionButton(
                      icon: Icons.auto_awesome,
                      label: 'Create',
                      onTap: () => context.go('/create'),
                    ),
                    _QuickActionButton(
                      icon: Icons.schedule,
                      label: 'Scheduler',
                      onTap: () => context.go('/scheduler'),
                    ),
                    _QuickActionButton(
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                      onTap: () {},
                    ),
                    _QuickActionButton(
                      icon: Icons.info_outline,
                      label: 'About us',
                      onTap: () => context.go('/home/about'),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 8, color: Color(0x22FFFFFF)),

              // Upcoming Posts (header + horizontal list)
              _buildSectionHeader(context, 'Upcoming Posts', 'View All', () {}),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _upcomingPosts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final p = _upcomingPosts[i];
                    return _UpcomingPostCard(
                      imageUrl: p['image'] as String,
                      platformIcon: p['icon'] as IconData,
                      date: p['date'] as String,
                      time: p['time'] as String,
                      caption: p['caption'] as String,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 8, color: Color(0x22FFFFFF)),

              // Performance Highlights
              _buildSectionHeader(
                context,
                'Performance Highlights',
                'Last 7 days',
                () {},
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  children: const [
                    Expanded(
                      child: _PerformanceStat(
                        label: 'Impressions',
                        value: '2,345',
                        change: '+15%',
                        isPositive: true,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _PerformanceStat(
                        label: 'Engagement',
                        value: '189',
                        change: '-2.3%',
                        isPositive: false,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CTA Gradient Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _CtaGradientCard(
                  onTap: () => context.go('/home/about'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildSectionHeader(
    BuildContext context,
    String title,
    String actionText,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          TextButton(onPressed: onTap, child: Text(actionText)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              // slightly translucent so background gradient shows through
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF0F2137)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _UpcomingPostCard extends StatelessWidget {
  final String imageUrl;
  final IconData platformIcon;
  final String date;
  final String time;
  final String caption;

  const _UpcomingPostCard({
    required this.imageUrl,
    required this.platformIcon,
    required this.date,
    required this.time,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 150,
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 110,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.black45),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details (overflow-safe)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(platformIcon, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$date • $time',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              constraints: const BoxConstraints(maxWidth: 90),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Scheduled',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 24,
                      width: 42,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: const [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          Positioned(
                            left: 16,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaGradientCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CtaGradientCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // CTA keeps its stronger gradient
        gradient: const LinearGradient(
          colors: [Color(0xFF082742), Color(0xFFF2B705)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to Spark Your Social Media Success?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join hundreds of Ethiopian businesses already creating amazing content with SocialSpark',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF2B705),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onPressed: onTap,
            child: const Text(
              'About Us →',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

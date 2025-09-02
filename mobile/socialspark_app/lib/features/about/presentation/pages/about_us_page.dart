import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About us'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        children: const [
          _FeatureCard(
            icon: Icons.auto_awesome_outlined,
            iconColor: Color(0xFF0F2137),
            iconBackgroundColor: Color(0xFFE7F0FF),
            title: 'AI Content Generation',
            description:
                'Generate captions, hashtags, and visuals from simple ideas using advanced AI.',
          ),
          SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.language,
            iconColor: Color(0xFFF2B705),
            iconBackgroundColor: Color(0xFFFFF8E1),
            title: 'Bilingual Support',
            description:
                'Create content in both English and Amharic with cultural context understanding.',
          ),
          SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.schedule,
            iconColor: Color(0xFF4CAF50),
            iconBackgroundColor: Color(0xFFE8F5E9),
            title: 'Smart Scheduling',
            description:
                'Schedule posts for optimal engagement times with Ethiopian audience insights.',
          ),
          SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.videocam_outlined,
            iconColor: Color(0xFFFFA000),
            iconBackgroundColor: Color(0xFFFFECB3),
            title: 'Multi-Platform',
            description: 'Optimized content for Instagram and TikTok videos.',
          ),
          SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.people_outline,
            iconColor: Color(0xFF009688),
            iconBackgroundColor: Color(0xFFE0F2F1),
            title: 'Ethiopian Focus',
            description:
                'Built specifically for Ethiopian businesses with local market understanding.',
          ),
          SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.palette_outlined,
            iconColor: Color(0xFF3F51B5),
            iconBackgroundColor: Color(0xFFE8EAF6),
            title: 'Brand Presets',
            description:
                'Save your brand colors, fonts, and style preferences for consistent content.',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F2137),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

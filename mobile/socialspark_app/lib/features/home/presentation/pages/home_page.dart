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
        padding: const EdgeInsets.all(20),
        children: [
          // Top Row (Logo + Name)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2137),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'SocailSpark',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Big title
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
              children: [
                TextSpan(text: 'Socail'),
                TextSpan(
                    text: 'Spark',
                    style: TextStyle(color: Color(0xFFF2B705))),
              ],
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'AI-Powered Content Creation Toolkit for Instagram & TikTok',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          const Text(
            'Create engaging social media content in seconds with bilingual support (English/Amharic). Perfect for Ethiopian SMEs and creators.',
          ),
          const SizedBox(height: 20),

          // Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/home/about'), // Corrected route
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('About us'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Sign out'), // Changed from Sign in
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Everything You Need to Spark Your Social Media',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('From idea to published post in minutes, not hours'),
          const SizedBox(height: 24),

          // Gradient card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  onPressed: () => context.go('/signup'), // Corrected to signup
                  child: const Text(
                    'Start Your free trial →',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

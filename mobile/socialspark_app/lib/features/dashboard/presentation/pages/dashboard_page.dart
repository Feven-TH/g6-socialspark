import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/features/settings/presentation/pages/settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;

  late final pages = [
    _buildHomeContent(), // 👈 replaced with full landing page
    _buildLibraryContent(),
    const Center(child: Text("Brand")),
    const Center(child: Text("Settings")),
  ];

  Widget _buildLibraryContent() {
    return const Center(
      child: Text("Swipe up from the bottom to see the library"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[_index]),

      // Floating button in the center
      floatingActionButton: FloatingActionButton(
  onPressed: () => context.go('/create'),   // ← was showing a SnackBar
  backgroundColor: const Color(0xFF0F2137),
  child: const Icon(Icons.add, color: Colors.white),
),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom nav bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, "Home", 0),
              _navItem(Icons.star_border, "Library", 1),
              const SizedBox(width: 40),
              _navItem(Icons.palette_outlined, "Brand", 2),
              _navItem(Icons.settings, "Setting", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int idx) {
    final selected = _index == idx;
    return InkWell(
      onTap: () async {
        print('Tapped button: $label (index: $idx)');
        
        // Handle navigation for specific tabs
        switch (idx) {
          case 0: // Home
            setState(() => _index = 0);
            if (ModalRoute.of(context)?.settings.name != '/home') {
              context.go('/home');
            }
            break;
          case 1: // Library
            setState(() => _index = 1);
            print('Navigating to /library');
            context.go('/library');
            break;
          case 2: // Brand
            setState(() => _index = 2);
            // Handle brand navigation if needed
            break;
          case 3: // Settings
            print('Navigating to /settings');
            try {
              await context.push('/settings');
              // Update the selected index when returning from settings
              setState(() => _index = 0);
            } catch (e) {
              print('Error navigating to settings: $e');
            }
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: selected ? const Color(0xFF0F2137) : Colors.black54),
          Text(label,
              style: TextStyle(
                  color: selected ? const Color(0xFF0F2137) : Colors.black54)),
        ],
      ),
    );
  }

  /// 👇 Full marketing/landing page goes here
  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Logo + Title
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
            const Text('SocailSpark',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 24),

        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black),
            children: [
              TextSpan(text: 'Socail'),
              TextSpan(text: 'Spark', style: TextStyle(color: Color(0xFFF2B705))),
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

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/home/about'),
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
                child: const Text('Sign in'),
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
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: () => context.go('/login'),
                child: const Text(
                  'Start Your free trial →',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

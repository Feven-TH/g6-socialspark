import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';
import 'edit_profile_page.dart';
import 'language_theme_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 3, // Settings tab
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
          title: const Text("Settings", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0F2137),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingsItem(
              context,
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),
            _buildSettingsItem(
              context,
              icon: Icons.language,
              title: "Language & Theme",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageThemePage()),
                );
              },
            ),
            const Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildSettingsItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0F2137)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F2137),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF0F2137)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

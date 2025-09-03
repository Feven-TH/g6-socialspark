import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'language_theme_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
            },
          ),
          ListTile(
            title: const Text("Language & Theme"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageThemePage()));
            },
          ),
          const Divider(),
          const ListTile(title: Text("Privacy Policy")),
          const ListTile(title: Text("Terms & Conditions")),
        ],
      ),
    );
  }
}

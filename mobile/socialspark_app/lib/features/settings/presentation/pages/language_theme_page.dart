import 'package:flutter/material.dart';

class LanguageThemePage extends StatefulWidget {
  const LanguageThemePage({super.key});

  @override
  State<LanguageThemePage> createState() => _LanguageThemePageState();
}

class _LanguageThemePageState extends State<LanguageThemePage> {
  String selectedLanguage = "English";
  String theme = "Light";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language & Theme")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedLanguage,
              items: ["English", "Amharic"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => selectedLanguage = value!),
            ),
            DropdownButton<String>(
              value: theme,
              items: ["Light", "Dark"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => theme = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Confirm"))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text("Language & Theme", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F2137),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Language',
                      style: TextStyle(color: Color(0xFF0F2137), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedLanguage,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Color(0xFF0F2137), fontSize: 16),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0F2137)),
                          items: ["English", "Amharic"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: const TextStyle(color: Color(0xFF0F2137))),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => selectedLanguage = value!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Theme',
                      style: TextStyle(color: Color(0xFF0F2137), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: theme,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Color(0xFF0F2137), fontSize: 16),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0F2137)),
                          items: ["Light", "Dark"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: const TextStyle(color: Color(0xFF0F2137))),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => theme = value!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement theme and language change
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2137),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

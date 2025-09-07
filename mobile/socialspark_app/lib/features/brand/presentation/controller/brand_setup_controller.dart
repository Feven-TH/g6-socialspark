import 'package:flutter/material.dart';

class BrandDraft {
  String businessName = '';
  String businessType = 'Cafe/Restaurant';
  String description = '';

  Color primary = const Color(0xFF003366);
  Color secondary = const Color(0xFFF9C51C);
  Color accent = const Color(0xFFE74C3C);

  String? logoPath;
  final List<String> defaultHashtags = ['AddisAbebaCafe', 'EthiopianCoffee'];

  String brandVoice = 'Friendly & Casual';
  String audience = 'Coffee Enthusiasts';
}

class BrandSetupController extends ChangeNotifier {
  final BrandDraft draft = BrandDraft();

  void setBusinessName(String v) { draft.businessName = v; notifyListeners(); }
  void setBusinessType(String v) { draft.businessType = v; notifyListeners(); }
  void setDescription(String v) { draft.description = v; notifyListeners(); }

  void setPrimary(Color c) { draft.primary = c; notifyListeners(); }
  void setSecondary(Color c) { draft.secondary = c; notifyListeners(); }
  void setAccent(Color c) { draft.accent = c; notifyListeners(); }

  void addHashtag(String tag) {
    if (tag.isEmpty) return;
    if (!tag.startsWith('#')) tag = '#$tag';
    if (!draft.defaultHashtags.contains(tag)) {
      draft.defaultHashtags.add(tag);
      notifyListeners();
    }
  }
  void removeHashtag(String tag) {
    draft.defaultHashtags.remove(tag);
    notifyListeners();
  }

  void setVoice(String v) { draft.brandVoice = v; notifyListeners(); }
  void setAudience(String v) { draft.audience = v; notifyListeners(); }
}

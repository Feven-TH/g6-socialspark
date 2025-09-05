class BrandPreset {
  final String? name;
  final List<String>? colors;
  final String? tone;
  final List<String>? defaultHashtags;
  final String? footerText;

  const BrandPreset({this.name, this.colors, this.tone, this.defaultHashtags, this.footerText});

  Map<String, dynamic> toJson() => {
    if (name != null) "name": name,
    if (colors != null) "colors": colors,
    if (tone != null) "tone": tone,
    if (defaultHashtags != null) "default_hashtags": defaultHashtags,
    if (footerText != null) "footer_text": footerText,
  };
}

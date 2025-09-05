// mobile/socialspark_app/lib/features/create/data/models/brand_preset.dart
import 'package:equatable/equatable.dart';

class BrandPreset extends Equatable {
  const BrandPreset({
    required this.name,
    required this.colors,
    required this.tone,
    required this.defaultHashtags,
    required this.footerText,
  });

  final String name;
  final List<String> colors;
  final String tone;
  final List<String> defaultHashtags;
  final String footerText;

  BrandPreset copyWith({
    String? name,
    List<String>? colors,
    String? tone,
    List<String>? defaultHashtags,
    String? footerText,
  }) {
    return BrandPreset(
      name: name ?? this.name,
      colors: colors ?? this.colors,
      tone: tone ?? this.tone,
      defaultHashtags: defaultHashtags ?? this.defaultHashtags,
      footerText: footerText ?? this.footerText,
    );
  }

  /// CamelCase JSON (good for local storage or generic serialization).
  Map<String, dynamic> toJson() => {
        'name': name,
        'colors': colors,
        'tone': tone,
        'defaultHashtags': defaultHashtags,
        'footerText': footerText,
      };

  /// Snake_case JSON (exactly what the backend expects).
  Map<String, dynamic> toApiJson() => {
        'name': name,
        'colors': colors,
        'tone': tone,
        'default_hashtags': defaultHashtags,
        'footer_text': footerText,
      };

  factory BrandPreset.fromJson(Map<String, dynamic> json) => BrandPreset(
        name: (json['name'] ?? '').toString(),
        colors: (json['colors'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        tone: (json['tone'] ?? '').toString(),
        defaultHashtags: (json['defaultHashtags'] ??
                json['default_hashtags'] ??
                const []) is List
            ? List<String>.from(
                (json['defaultHashtags'] ?? json['default_hashtags'])!.map((e) => e.toString()))
            : const [],
        footerText: (json['footerText'] ?? json['footer_text'] ?? '').toString(),
      );

  @override
  List<Object?> get props => [name, colors, tone, defaultHashtags, footerText];

  @override
  String toString() =>
      'BrandPreset(name: $name, tone: $tone, colors: $colors, hashtags: $defaultHashtags)';
}

// mobile/socialspark_app/lib/features/create/data/models/requests.dart
import 'package:equatable/equatable.dart';

import 'brand_preset.dart';

/// Caption generation request
class CaptionRequest extends Equatable {
  const CaptionRequest({
    required this.idea,
    required this.platform,
    this.brandPresets,
  });

  final String idea;
  final String platform; // e.g., "instagram", "tiktok"
  final BrandPreset? brandPresets;

  CaptionRequest copyWith({
    String? idea,
    String? platform,
    BrandPreset? brandPresets,
  }) {
    return CaptionRequest(
      idea: idea ?? this.idea,
      platform: platform ?? this.platform,
      brandPresets: brandPresets ?? this.brandPresets,
    );
  }

  /// Backend expects: { idea, platform, brand_presets? }
  Map<String, dynamic> toApiJson() => {
        'idea': idea,
        'platform': platform,
        if (brandPresets != null) 'brand_presets': brandPresets!.toApiJson(),
      };

  @override
  List<Object?> get props => [idea, platform, brandPresets];
}

/// Image generation bootstrap request
class ImageGenerationRequest extends Equatable {
  const ImageGenerationRequest({
    required this.prompt,
    required this.style,
    required this.aspectRatio,
    required this.platform,
    this.brandPresets,
  });

  final String prompt;
  final String style;        // e.g., "realistic"
  final String aspectRatio;  // e.g., "1:1", "9:16"
  final String platform;     // e.g., "instagram", "tiktok"
  final BrandPreset? brandPresets;

  ImageGenerationRequest copyWith({
    String? prompt,
    String? style,
    String? aspectRatio,
    String? platform,
    BrandPreset? brandPresets,
  }) {
    return ImageGenerationRequest(
      prompt: prompt ?? this.prompt,
      style: style ?? this.style,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      platform: platform ?? this.platform,
      brandPresets: brandPresets ?? this.brandPresets,
    );
  }

  /// Backend expects: { prompt, style, aspect_ratio, platform, brand_presets? }
  Map<String, dynamic> toApiJson() => {
        'prompt': prompt,
        'style': style,
        'aspect_ratio': aspectRatio,
        'platform': platform,
        if (brandPresets != null) 'brand_presets': brandPresets!.toApiJson(),
      };

  @override
  List<Object?> get props => [prompt, style, aspectRatio, platform, brandPresets];
}

/// Optional convenience model if you want to build the POST /generate/storyboard body
class StoryboardRequest extends Equatable {
  const StoryboardRequest({
    required this.idea,
    required this.language,
    required this.numberOfShots,
    required this.platform,
    required this.cta,
    this.brandPresets,
  });

  final String idea;
  final String language;     // e.g., "english"
  final int numberOfShots;   // e.g., 5
  final String platform;     // e.g., "instagram"
  final String cta;          // required per backend
  final BrandPreset? brandPresets;

  Map<String, dynamic> toApiJson() => {
        'idea': idea,
        'language': language,
        'number_of_shots': numberOfShots,
        'platform': platform,
        'cta': cta,
        if (brandPresets != null) 'brand_presets': brandPresets!.toApiJson(),
      };

  @override
  List<Object?> get props =>
      [idea, language, numberOfShots, platform, cta, brandPresets];
}

/// Optional shot + render payload models if you want stronger typing for /render/video
class Shot extends Equatable {
  const Shot({required this.duration, required this.text});

  final int duration; // seconds
  final String text;

  Map<String, dynamic> toApiJson() => {
        'duration': duration,
        'text': text,
      };

  factory Shot.fromJson(Map<String, dynamic> json) => Shot(
        duration: (json['duration'] is num)
            ? (json['duration'] as num).round()
            : int.tryParse('${json['duration']}') ?? 4,
        text: (json['text'] ?? json['caption'] ?? json['title'] ?? '').toString(),
      );

  @override
  List<Object?> get props => [duration, text];
}

class VideoRenderRequest extends Equatable {
  const VideoRenderRequest({
    required this.shots,
    required this.music,
  });

  final List<Shot> shots;
  final String music;

  Map<String, dynamic> toApiJson() => {
        'shots': shots.map((s) => s.toApiJson()).toList(),
        'music': music,
      };

  @override
  List<Object?> get props => [shots, music];
}

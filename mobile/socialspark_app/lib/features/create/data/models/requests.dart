import 'brand_preset.dart';

class ImageGenerationRequest {
  final String prompt;
  final String style;         // e.g. "realistic"
  final String aspectRatio;   // e.g. "1:1", "9:16"
  final BrandPreset? brandPresets;
  final String? platform;     // "instagram", "tiktok", ...

  const ImageGenerationRequest({
    required this.prompt,
    this.style = "realistic",
    this.aspectRatio = "1:1",
    this.brandPresets,
    this.platform,
  });

  Map<String, dynamic> toJson() => {
    "prompt": prompt,
    "style": style,
    "aspect_ratio": aspectRatio,
    if (brandPresets != null) "brand_presets": brandPresets!.toJson(),
    if (platform != null) "platform": platform,
  };
}
class CaptionRequest {
  final String idea;                 // rename for clarity
  final BrandPreset? brandPresets;
  final String? platform;

  const CaptionRequest({
    required this.idea,
    this.brandPresets,
    this.platform,
  });

  Map<String, dynamic> toJson() => {
    // ✅ Backend wants `idea`, not `prompt`
    "idea": idea,
    if (brandPresets != null) "brand_presets": brandPresets!.toJson(),
    if (platform != null) "platform": platform,
  };
}

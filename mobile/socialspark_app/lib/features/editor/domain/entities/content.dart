import 'package:equatable/equatable.dart';

class Content extends Equatable {
  final String id;
  final String caption;
  final String imageUrl;
  final String? hashtags;
  final String? fontStyle;
  final double? fontSize;
  final String? textColor;
  final String? backgroundColor;

  const Content({
    required this.id,
    required this.caption,
    required this.imageUrl,
    this.hashtags,
    this.fontStyle,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
  });

  // A method to create a new instance with updated properties.
  // This is useful for immutability.
  Content copyWith({
    String? id,
    String? caption,
    String? imageUrl,
    String? hashtags,
    String? fontStyle,
    double? fontSize,
    String? textColor,
    String? backgroundColor,
  }) {
    return Content(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      hashtags: hashtags ?? this.hashtags,
      fontStyle: fontStyle ?? this.fontStyle,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  List<Object?> get props => [
    id,
    caption,
    imageUrl,
    hashtags,
    fontStyle,
    fontSize,
    textColor,
    backgroundColor,
  ];
}
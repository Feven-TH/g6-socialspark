import '../../domain/entities/content.dart';

class ContentModel {
  final String id;
  final String caption;
  final String imageUrl;
  final String? hashtags;
  final String? fontStyle;
  final double? fontSize;

  ContentModel({
    required this.id,
    required this.caption,
    required this.imageUrl,
    this.hashtags,
    this.fontStyle,
    this.fontSize,
  });

  // Factory constructor to create a ContentModel from a JSON map.
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      caption: json['caption'],
      imageUrl: json['imageUrl'],
      hashtags: json['hashtags'],
      fontStyle: json['fontStyle'],
      fontSize: json['fontSize']?.toDouble(),
    );
  }

  // Method to convert a ContentModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'imageUrl': imageUrl,
      'hashtags': hashtags,
      'fontStyle': fontStyle,
      'fontSize': fontSize,
    };
  }

  // Method to convert the data layer model to a domain layer entity.
  // This is a crucial part of Clean Architecture.
  Content toEntity() {
    return Content(
      id: id,
      caption: caption,
      imageUrl: imageUrl,
      hashtags: hashtags,
      fontStyle: fontStyle,
      fontSize: fontSize,
    );
  }

  // Factory method to create a ContentModel from a domain entity.
  factory ContentModel.fromEntity(Content entity) {
    return ContentModel(
      id: entity.id,
      caption: entity.caption,
      imageUrl: entity.imageUrl,
      hashtags: entity.hashtags,
      fontStyle: entity.fontStyle,
      fontSize: entity.fontSize,
    );
  }
}
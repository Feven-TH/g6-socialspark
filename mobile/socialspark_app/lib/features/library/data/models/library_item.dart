
import 'package:equatable/equatable.dart';

enum MediaType { image, video }

class LibraryItem extends Equatable {
  final String id;
  final String mediaUrl;
  final String caption;
  final List<String> hashtags;
  final String platform;
  final MediaType type;
  final DateTime createdAt;

  const LibraryItem({
    required this.id,
    required this.mediaUrl,
    required this.caption,
    required this.hashtags,
    required this.platform,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, mediaUrl, caption, hashtags, platform, type, createdAt];
}

import '../entities/content.dart';

abstract class ContentRepository {
  // Get a single piece of content by its ID.
  Future<Content> getContent(String contentId);

  // Save a new piece of content.
  Future<Content> createContent(Content content);

  // Update an existing piece of content.
  Future<Content> updateContent(Content content);
}
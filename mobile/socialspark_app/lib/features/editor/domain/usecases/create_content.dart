import '../entities/content.dart';
import '../repositories/content_repository.dart';

class CreateContent {
  final ContentRepository repository;

  CreateContent(this.repository);

  Future<Content> call(Content content) async {
    // You can add business logic here before creating the content.
    // For example, validating caption length or hashtag count.
    if (content.caption.isEmpty) {
      throw Exception("Caption cannot be empty.");
    }
    // More validation logic...

    return await repository.createContent(content);
  }
}
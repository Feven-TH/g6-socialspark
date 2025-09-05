import '../entities/content.dart';
import '../repositories/content_repository.dart';

class UpdateContent {
  final ContentRepository repository;

  UpdateContent(this.repository);

  Future<Content> call(Content content) async {
    // You can add business logic here before updating the content.
    // e.g., check for a valid ID.
    if (content.id.isEmpty) {
      throw Exception("Content ID is required for updating.");
    }

    return await repository.updateContent(content);
  }
}
import '../entities/content.dart';
import '../repositories/content_repository.dart';

class GetContent {
  final ContentRepository repository;

  GetContent(this.repository);

  Future<Content> call(String contentId) async {
    return await repository.getContent(contentId);
  }
}
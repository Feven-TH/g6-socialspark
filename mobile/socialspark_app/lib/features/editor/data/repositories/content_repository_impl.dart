import '../../domain/entities/content.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_api_data_source.dart';
import '../models/content_model.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentApiDataSource remoteDataSource;

  ContentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Content> getContent(String contentId) async {
    try {
      final contentModel = await remoteDataSource.getContent(contentId);
      return contentModel.toEntity();
    } catch (e) {
      // You can implement more sophisticated error handling here
      throw Exception('Failed to fetch content from repository');
    }
  }

  @override
  Future<Content> createContent(Content content) async {
    try {
      final contentModel = ContentModel.fromEntity(content);
      final newContentModel = await remoteDataSource.createContent(contentModel);
      return newContentModel.toEntity();
    } catch (e) {
      throw Exception('Failed to create content from repository');
    }
  }

  @override
  Future<Content> updateContent(Content content) async {
    try {
      final contentModel = ContentModel.fromEntity(content);
      final updatedContentModel = await remoteDataSource.updateContent(contentModel);
      return updatedContentModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update content from repository');
    }
  }
}
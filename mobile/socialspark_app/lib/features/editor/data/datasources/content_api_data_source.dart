import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/content_model.dart';

abstract class ContentApiDataSource {
  Future<ContentModel> getContent(String id);
  Future<ContentModel> createContent(ContentModel content);
  Future<ContentModel> updateContent(ContentModel content);
}

class ContentApiDataSourceImpl implements ContentApiDataSource {
  final http.Client client;

  ContentApiDataSourceImpl({required this.client});

  @override
  Future<ContentModel> getContent(String id) async {
    final response = await client.get(
      Uri.parse('https://your-socialspark-api.com/content/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ContentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load content');
    }
  }

  @override
  Future<ContentModel> createContent(ContentModel content) async {
    final response = await client.post(
      Uri.parse('https://your-socialspark-api.com/content'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(content.toJson()),
    );

    if (response.statusCode == 201) {
      return ContentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create content');
    }
  }

  @override
  Future<ContentModel> updateContent(ContentModel content) async {
    final response = await client.put(
      Uri.parse('https://your-socialspark-api.com/content/${content.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(content.toJson()),
    );

    if (response.statusCode == 200) {
      return ContentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update content');
    }
  }
}
import 'package:equatable/equatable.dart';
import 'package:socialspark_app/features/editor/domain/entities/content.dart';

enum ContentEditorStatus { initial, loading, loaded, saved, error }

class ContentEditorState extends Equatable {
  final ContentEditorStatus status;
  final Content? content;
  final String? errorMessage;

  const ContentEditorState({
    this.status = ContentEditorStatus.initial,
    this.content,
    this.errorMessage,
  });

  ContentEditorState copyWith({
    ContentEditorStatus? status,
    Content? content,
    String? errorMessage,
  }) {
    return ContentEditorState(
      status: status ?? this.status,
      content: content ?? this.content,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, content, errorMessage];
}
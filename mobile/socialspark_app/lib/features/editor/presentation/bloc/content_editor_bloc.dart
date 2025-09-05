import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/content.dart';
import '../../domain/usecases/create_content.dart';
import '../../domain/usecases/update_content.dart';
import 'content_editor_event.dart';
import 'content_editor_state.dart';

class ContentEditorBloc extends Bloc<ContentEditorEvent, ContentEditorState> {
  final CreateContent createContent;
  final UpdateContent updateContent;

  ContentEditorBloc({
    required this.createContent,
    required this.updateContent,
  }) : super(const ContentEditorState()) {
    on<InitializeContent>(_onInitializeContent);
    on<CaptionChanged>(_onCaptionChanged);
    on<HashtagsChanged>(_onHashtagsChanged);
    on<FontSizeChanged>(_onFontSizeChanged);
    on<SaveContentEvent>(_onSaveContent);
    on<PostContentEvent>(_onPostContent);
  }

  void _onInitializeContent(
    InitializeContent event,
    Emitter<ContentEditorState> emit,
  ) {
    // This creates a new, empty content entity with the correct properties.
    final newContent = Content(
      id: '',
      caption: '',
      imageUrl: '',
      // Optional properties can be set to null or a default value
      hashtags: null,
      fontStyle: null,
      fontSize: 16.0,
    );
    emit(state.copyWith(
      status: ContentEditorStatus.initial,
      content: newContent,
    ));
  }

  void _onCaptionChanged(
    CaptionChanged event,
    Emitter<ContentEditorState> emit,
  ) {
    if (state.content != null) {
      final updatedContent = state.content!.copyWith(caption: event.caption);
      emit(state.copyWith(content: updatedContent));
    }
  }

  void _onHashtagsChanged(
    HashtagsChanged event,
    Emitter<ContentEditorState> emit,
  ) {
    if (state.content != null) {
      final updatedContent = state.content!.copyWith(hashtags: event.hashtags);
      emit(state.copyWith(content: updatedContent));
    }
  }

  void _onFontSizeChanged(
    FontSizeChanged event,
    Emitter<ContentEditorState> emit,
  ) {
    if (state.content != null) {
      final updatedContent = state.content!.copyWith(fontSize: event.fontSize);
      emit(state.copyWith(content: updatedContent));
    }
  }

  Future<void> _onSaveContent(
    SaveContentEvent event,
    Emitter<ContentEditorState> emit,
  ) async {
    emit(state.copyWith(status: ContentEditorStatus.loading));
    try {
      if (state.content != null) {
        final savedContent = await updateContent(state.content!);
        emit(state.copyWith(status: ContentEditorStatus.saved, content: savedContent));
      }
    } catch (e) {
      emit(state.copyWith(status: ContentEditorStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onPostContent(
    PostContentEvent event,
    Emitter<ContentEditorState> emit,
  ) async {
    emit(state.copyWith(status: ContentEditorStatus.loading));
    try {
      if (state.content != null) {
        final postedContent = await updateContent(state.content!);
        emit(state.copyWith(status: ContentEditorStatus.saved, content: postedContent));
      }
    } catch (e) {
      emit(state.copyWith(status: ContentEditorStatus.error, errorMessage: e.toString()));
    }
  }
}

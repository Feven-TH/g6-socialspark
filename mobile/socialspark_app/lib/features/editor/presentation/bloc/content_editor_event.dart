import 'package:equatable/equatable.dart';

abstract class ContentEditorEvent extends Equatable {
  const ContentEditorEvent();

  @override
  List<Object?> get props => [];
}

class InitializeContent extends ContentEditorEvent {}

class CaptionChanged extends ContentEditorEvent {
  final String caption;
  const CaptionChanged(this.caption);

  @override
  List<Object?> get props => [caption];
}

class HashtagsChanged extends ContentEditorEvent {
  final String hashtags;
  const HashtagsChanged(this.hashtags);

  @override
  List<Object?> get props => [hashtags];
}

class FontSizeChanged extends ContentEditorEvent {
  final double fontSize;
  const FontSizeChanged(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}

class TextColorChanged extends ContentEditorEvent {
  final String colorHex;
  const TextColorChanged(this.colorHex);

  @override
  List<Object?> get props => [colorHex];
}

class BackgroundColorChanged extends ContentEditorEvent {
  final String colorHex;
  const BackgroundColorChanged(this.colorHex);

  @override
  List<Object?> get props => [colorHex];
}

class SaveContentEvent extends ContentEditorEvent {}

class PostContentEvent extends ContentEditorEvent {}
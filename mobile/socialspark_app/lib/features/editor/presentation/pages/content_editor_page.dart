import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialspark_app/features/editor/domain/entities/content.dart';
import '../bloc/content_editor_bloc.dart';
import '../bloc/content_editor_state.dart';
import '../bloc/content_editor_event.dart';
import 'package:socialspark_app/features/editor/presentation/widgets/visual_preview.dart';
import 'package:socialspark_app/features/editor/presentation/widgets/caption_input.dart';
import 'package:socialspark_app/features/editor/presentation/widgets/hashtag_input.dart';

class ContentEditorPage extends StatelessWidget {
  const ContentEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.go('/home'); // Navigate to the /home route using GoRouter
          },
        ),
        title: Text(
          'Content Editor',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onSelected: (value) {
              if (value == 'undo') {
                // Handle undo
              } else if (value == 'redo') {
                // Handle redo
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'undo',
                child: ListTile(
                  leading: Icon(Icons.undo_outlined),
                  title: Text('Undo'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'redo',
                child: ListTile(
                  leading: Icon(Icons.redo_outlined),
                  title: Text('Redo'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<ContentEditorBloc>(context).add(SaveContentEvent());
                      },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<ContentEditorBloc>(context).add(PostContentEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Post', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ContentEditorBloc, ContentEditorState>(
        builder: (context, state) {
          if (state.status == ContentEditorStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ContentEditorStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.content == null) {
            return const Center(child: Text('No content to display.'));
          }

          final content = state.content!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Visual Preview', Icons.photo_camera_outlined),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: VisualPreview(content: content),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Caption', Icons.subject_outlined),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: CaptionInput(
                      initialValue: content.caption ?? '',
                      onChanged: (caption) {
                        BlocProvider.of<ContentEditorBloc>(context).add(CaptionChanged(caption));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Hashtags', Icons.tag_sharp),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: HashtagInput(
                      initialValue: content.hashtags ?? '',
                      onChanged: (hashtags) {
                        BlocProvider.of<ContentEditorBloc>(context).add(HashtagsChanged(hashtags));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Export', Icons.download_outlined),
                _ExportSection(),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        const TabBar(
                          indicatorColor: Colors.black,
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Style'),
                            Tab(text: 'Presets'),
                            Tab(text: 'Layers'),
                          ],
                          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSection('Font Size', child: _FontSizeSlider(
                                      content: content,
                                      onChanged: (value) {
                                        BlocProvider.of<ContentEditorBloc>(context).add(FontSizeChanged(value));
                                      },
                                    )),
                                    const SizedBox(height: 16),
                                    _buildSection('Text Color', child: _ColorPicker(
                                      initialColor: content.textColor ?? '#000000',
                                      onColorChanged: (colorHex) {
                                        BlocProvider.of<ContentEditorBloc>(context).add(TextColorChanged(colorHex));
                                      },
                                    )),
                                    const SizedBox(height: 16),
                                    _buildSection('Background Overlay', child: _ColorPicker(
                                      initialColor: content.backgroundColor ?? '#FFFFFF',
                                      onColorChanged: (colorHex) {
                                        BlocProvider.of<ContentEditorBloc>(context).add(BackgroundColorChanged(colorHex));
                                      },
                                    )),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: _BrandPresets(),
                              ),
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LayerItem(label: 'Text Overlay', isVisible: true, onToggle: () {}),
                                    _LayerItem(label: 'Background Image', isVisible: true, onToggle: () {}),
                                    _LayerItem(label: 'Logo', isVisible: false, onToggle: () {}),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(padding: const EdgeInsets.all(12.0), child: child),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final Content content;
  final ValueChanged<double> onChanged;

  const _FontSizeSlider({required this.content, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Font Size'),
        Expanded(
          child: Slider(
            value: content.fontSize ?? 16.0,
            min: 10,
            max: 40,
            onChanged: onChanged,
          ),
        ),
        Text('${(content.fontSize ?? 16.0).round()}px'),
      ],
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String initialColor;
  final ValueChanged<String> onColorChanged;

  const _ColorPicker({required this.initialColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color(int.parse('FF${initialColor.substring(1)}', radix: 16)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: initialColor),
            onChanged: onColorChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandPresets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _PresetColorBox(color: Colors.orange.shade700),
        _PresetColorBox(color: Colors.blue.shade900),
        _PresetColorBox(color: Colors.green.shade600),
      ],
    );
  }
}

class _PresetColorBox extends StatelessWidget {
  final Color color;

  const _PresetColorBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle preset selection
      },
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}')),
      ),
    );
  }
}


class _LayerItem extends StatelessWidget {
  final String label;
  final bool isVisible;
  final VoidCallback onToggle;

  const _LayerItem({required this.label, required this.isVisible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: isVisible ? Colors.black : Colors.grey,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

class _ExportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Export'),
                  ),
                  DropdownButton<String>(
                    value: 'Instagram Post (1:1)',
                    items: ['Instagram Post (1:1)', 'Facebook Post', 'Twitter Post']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.download_outlined),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
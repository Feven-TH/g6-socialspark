import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';

import '../../../../core/network/api_client.dart';
import '../../../create/data/datasources/create_remote_ds.dart';
import '../../../create/data/models/brand_preset.dart';
import '../../../create/data/models/requests.dart';
import '../widgets/video_generation_section.dart';
import '../widgets/image_generation_section.dart';
import '../../../library/data/models/library_item.dart';
import '../../../library/data/datasources/library_local_ds.dart';
import 'package:socialspark_app/features/editor/domain/entities/content.dart';

class CreateContentPage extends StatefulWidget {
  const CreateContentPage({super.key});
  @override
  State<CreateContentPage> createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  late final CreateRemoteDataSource _ds;
  final LibraryLocalDataSource _libraryDs = LibraryLocalDataSource.instance;

  // Step 1 inputs
  final _ideaCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();

  final _platforms = const ['instagram', 'tiktok'];
  final _tones = const ['Playful', 'Professional', 'Casual', 'Elegant'];

  String _platform = 'instagram';
  String _tone = 'Playful';
  List<String> _hashtags = ['AddisAbebaCafe', 'EthiopianCoffee'];

  String? _error;
  bool _loadingCaption = false;

  // Last generated content (for schedule button)
  Map<String, dynamic>? _lastGenerated;

  final GlobalKey<VideoGenerationSectionState> _videoKey =
      GlobalKey<VideoGenerationSectionState>();
  final GlobalKey<ImageGenerationSectionState> _imageKey =
      GlobalKey<ImageGenerationSectionState>();

  @override
  void initState() {
    super.initState();
    _ds = CreateRemoteDataSource(ApiClient());
    _ideaCtrl.text = 'A man having a coffee at a cafe';
    _ctaCtrl.text = 'call and reserve';
  }

  @override
  void dispose() {
    _ideaCtrl.dispose();
    _captionCtrl.dispose();
    _ctaCtrl.dispose();
    super.dispose();
  }

  BrandPreset _brand() => BrandPreset(
        name: "Wildlife",
        colors: ["#FBBF24", "#0D2A4B"],
        tone: _tone,
        defaultHashtags: _hashtags,
        footerText: "Wildlife 2025",
      );

  // ---------------- Step 1: Caption ----------------
  Future<void> _generateCaption() async {
    setState(() {
      _loadingCaption = true;
      _error = null;
    });

    final idea = _ideaCtrl.text.trim().isEmpty
        ? "A man having a coffee at a cafe"
        : _ideaCtrl.text.trim();

    try {
      final caption = await _ds.generateCaption(
        CaptionRequest(
          idea: idea,
          brandPresets: _brand(),
          platform: _platform,
        ),
      );

      setState(() {
        _captionCtrl.text = caption;
        _loadingCaption = false;
      });
    } catch (e) {
      setState(() {
        _loadingCaption = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _exportClipboard() async {
    final text = StringBuffer()
      ..writeln(_captionCtrl.text)
      ..writeln()
      ..writeln(_hashtags.map((h) => '#$h').join(' '));
    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied caption + hashtags')),
    );
  }

  Future<void> _scheduleFromLast() async {
    final content = _lastGenerated;
    if (content == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate image or video first')),
      );
      return;
    }
    context.push('/scheduler', extra: {
      'mediaUrl': content['url'],
      'type': content['type'] ?? 'image',
      'caption': _captionCtrl.text,
      'hashtags': _hashtags,
      'platform': _platform,
    });
  }

  Future<void> _saveToLibrary({
    required String mediaUrl,
    required String taskId,
    required MediaType type,
  }) async {
    final item = LibraryItem(
      id: taskId,
      mediaUrl: mediaUrl,
      caption: _captionCtrl.text,
      hashtags: _hashtags,
      platform: _platform,
      type: type,
      createdAt: DateTime.now(),
    );
    await _libraryDs.saveLibraryItem(item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to library')),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final toneChips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tones.map((t) {
        final selected = _tone == t;
        return ChoiceChip(
          label: Text(t),
          selected: selected,
          onSelected: (_) => setState(() => _tone = t),
        );
      }).toList(),
    );

    return MainScaffold(
      currentIndex: 2, // Create tab
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => const [
          SliverAppBar(
            title: Text('Create Content'),
            automaticallyImplyLeading: false,
            pinned: true,
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- STEP 1: CAPTION ----
            _stepHeader(1, 'Create caption',
                'Start with your idea, platform and tone.'),
            const SizedBox(height: 8),
            TextField(
              controller: _ideaCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Describe your idea… (e.g. 15s TikTok for wildlife conservation ad)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _platform,
                  decoration: const InputDecoration(
                      labelText: 'Platform', border: OutlineInputBorder()),
                  items: _platforms
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _platform = v ?? 'instagram'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ctaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'CTA (used for video)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            const Text('Tone'),
            const SizedBox(height: 6),
            toneChips,
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: Text(_loadingCaption ? 'Creating…' : 'Create caption'),
                onPressed: _loadingCaption ? null : _generateCaption,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_loadingCaption) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
            if (!_loadingCaption && _captionCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Caption', style: TextStyle(fontWeight: FontWeight.w600)),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _captionCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 12),
              const Text('# Hashtags',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _hashtags.map((h) => Chip(label: Text('#$h'))).toList(),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 12, runSpacing: 12, children: [
                OutlinedButton.icon(
                  onPressed: _generateCaption,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
                OutlinedButton.icon(
                  onPressed: _exportClipboard,
                  icon: const Icon(Icons.outbox),
                  label: const Text('Export'),
                ),
                OutlinedButton.icon(
                  onPressed: _scheduleFromLast,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule last generated'),
                ),
              ]),
            ],

            const SizedBox(height: 28),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),

            // ---- STEP 2: IMAGE ----
            _stepHeader(2, 'Generate image',
                'Create an image from the caption above.'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Generate Image'),
                    onPressed: () {
                      final baseIdea = _captionCtrl.text.trim().isNotEmpty
                          ? _captionCtrl.text.trim()
                          : _ideaCtrl.text.trim();
                      final idea = baseIdea.isEmpty
                          ? 'A man having a coffee at a cafe'
                          : baseIdea;

                      // Use the GlobalKey to start with the latest inputs.
                      _imageKey.currentState?.startWith(
                        idea: idea,
                        platform: _platform,
                        brandPreset: _brand(),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Mount with the SAME GlobalKey used above
            ImageGenerationSection(
              key: _imageKey,
              initialIdea: _captionCtrl.text.isNotEmpty
                  ? _captionCtrl.text
                  : _ideaCtrl.text,
              initialPlatform: _platform,
              brandPreset: _brand(),
              onImageReady: (url, taskId) {
                _lastGenerated = {'url': url, 'type': 'image'};
                _saveToLibrary(
                    mediaUrl: url, taskId: taskId, type: MediaType.image);
              },
            ),

            const SizedBox(height: 28),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),

            // ---- STEP 3: VIDEO ----
            _stepHeader(3, 'Generate video',
                'Turn your caption + CTA into a short video.'),
            const SizedBox(height: 8),
            // Video section contains its own "Generate Video" button.
            VideoGenerationSection(
              key: _videoKey,
              initialIdea: _captionCtrl.text.isNotEmpty
                  ? _captionCtrl.text
                  : _ideaCtrl.text,
              initialPlatform: _platform,
              initialCta: _ctaCtrl.text,
              brandPreset: _brand(),
              onVideoReady: (url, taskId) {
                _lastGenerated = {'url': url, 'type': 'video'};
                _saveToLibrary(
                    mediaUrl: url, taskId: taskId, type: MediaType.video);
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader(int n, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF0F2137),
          child: Text(
            '$n',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

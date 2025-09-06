import 'dart:async';
import 'package:dio/dio.dart';
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

class CreateContentPage extends StatefulWidget {
  const CreateContentPage({super.key});
  @override
  State<CreateContentPage> createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  late final CreateRemoteDataSource _ds;
  final LibraryLocalDataSource _libraryDs = LibraryLocalDataSource.instance;

  final _ideaCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();

  final _platforms = const ['instagram', 'tiktok'];
  final _types = const ['image post', 'video', 'story', 'reel'];
  final _tones = const ['Playful', 'Professional', 'Casual', 'Elegant'];

  String _platform = 'instagram';
  String _ctype = 'image post';
  String _tone = 'Playful';
  List<String> _hashtags = ['AddisAbebaCafe', 'EthiopianCoffee'];

  String? _imageUrl;
  String? _error;
  bool _loading = false;

  final GlobalKey<VideoGenerationSectionState> _videoKey =
      GlobalKey<VideoGenerationSectionState>();
  final GlobalKey<ImageGenerationSectionState> _imageKey =
      GlobalKey<ImageGenerationSectionState>();

  bool get _isVideoType =>
      _ctype.contains('video') || _ctype.contains('story') || _ctype.contains('reel');

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

  Future<void> _generateAll() async {
    setState(() {
      _loading = true;
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
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isVideoType) {
          _videoKey.currentState?.start();
        } else {
          _imageKey.currentState?.start();
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied caption + hashtags')),
      );
    }
  }

  Future<void> _saveToLibrary(String mediaUrl, String taskId) async {
    final item = LibraryItem(
      id: taskId,
      mediaUrl: mediaUrl,
      caption: _captionCtrl.text,
      hashtags: _hashtags,
      platform: _platform,
      type: _isVideoType ? MediaType.video : MediaType.image,
      createdAt: DateTime.now(),
    );
    await _libraryDs.saveLibraryItem(item);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to library')),
      );
    }
  }

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
      currentIndex: -1, // No tab selected
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const SliverAppBar(
            title: Text('Create Content'),
            automaticallyImplyLeading: false, // Removes back button
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Content idea',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _ideaCtrl,
              maxLines: 4,
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
                child: DropdownButtonFormField<String>(
                  value: _ctype,
                  decoration: const InputDecoration(
                      labelText: 'Content type', border: OutlineInputBorder()),
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _ctype = v ?? 'image post'),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            const Text('Tone'),
            const SizedBox(height: 6),
            toneChips,
            const SizedBox(height: 12),

            const Text('Call to Action (CTA) — used for video'),
            const SizedBox(height: 6),
            TextField(
              controller: _ctaCtrl,
              decoration: InputDecoration(
                hintText: 'e.g., call and reserve',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: Text(_loading
                    ? 'Generating…'
                    : (_isVideoType ? 'Generate (video)' : 'Generate (image)')),
                onPressed: _loading ? null : _generateAll,
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            if (_loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],

            if (!_loading && _captionCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Generated Content',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              const Text('Caption',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: TextField(
                    controller: _captionCtrl,
                    maxLines: 8,
                    decoration:
                        const InputDecoration(border: InputBorder.none)),
              ),
              const SizedBox(height: 12),

              const Text('# Hashtags',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _hashtags.map((h) => Chip(label: Text('#$h'))).toList()),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: [
                OutlinedButton.icon(
                    onPressed: _loading ? null : _generateAll,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerate')),
                OutlinedButton.icon(
                    onPressed: _exportClipboard,
                    icon: const Icon(Icons.outbox),
                    label: const Text('Export')),
                OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule')),
                OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share now')),
              ]),
            ],

            if (_isVideoType) ...[
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height: 16),
              Text('Video Generation',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              VideoGenerationSection(
                key: _videoKey,
                initialIdea: _ideaCtrl.text,
                initialPlatform: _platform,
                initialCta: _ctaCtrl.text,
                brandPreset: _brand(),
                onVideoReady: (url, taskId) {
                  _saveToLibrary(url, taskId);
                },
              ),
            ] else ...[
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height:.16),
              Text('Image Generation',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ImageGenerationSection(
                key: _imageKey,
                initialIdea: _ideaCtrl.text,
                initialPlatform: _platform,
                brandPreset: _brand(),
                onImageReady: (url, taskId) {
                  setState(() => _imageUrl = url);
                  _saveToLibrary(url, taskId);
                },
              ),
            ],
            const SizedBox(height: 16), // Reduced from 32
          ],
        ),
      ),
    );
  }
}

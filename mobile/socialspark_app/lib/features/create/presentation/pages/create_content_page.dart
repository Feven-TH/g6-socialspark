import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_client.dart';
import '../../../create/data/datasources/create_remote_ds.dart';
import '../../../create/data/models/brand_preset.dart';
import '../../../create/data/models/requests.dart';
import '../../../create/data/models/task_status.dart';
import '../widgets/video_generation_section.dart';

class CreateContentPage extends StatefulWidget {
  const CreateContentPage({super.key});
  @override
  State<CreateContentPage> createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  late final CreateRemoteDataSource _ds;

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

  // Typed key to call child's public start()
  final GlobalKey<VideoGenerationSectionState> _videoKey =
      GlobalKey<VideoGenerationSectionState>();

  bool get _isVideoType =>
      _ctype.contains('video') || _ctype.contains('story') || _ctype.contains('reel');

  @override
  void initState() {
    super.initState();
    _ds = CreateRemoteDataSource(ApiClient());
    _ideaCtrl.text = '15s TikTok for wildlife conservation ad';
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

  String _aspectForPlatform({required bool video}) {
    if (_platform == 'tiktok') return "9:16";
    if (video) return "9:16";
    return "1:1";
  }

  Future<void> _generateAll() async {
    setState(() {
      _loading = true;
      _error = null;
      if (!_isVideoType) _imageUrl = null; // image flow will set preview
    });

    final idea = _ideaCtrl.text.trim().isEmpty
        ? "15s TikTok for wildlife conservation ad"
        : _ideaCtrl.text.trim();

    try {
      // Always get a caption
      final caption = await _ds.generateCaption(
        CaptionRequest(
          idea: idea,
          brandPresets: _brand(),
          platform: _platform,
        ),
      );

      if (_isVideoType) {
        // Show the section and auto-start it
        setState(() {
          _captionCtrl.text = caption;
          _loading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _videoKey.currentState?.start();
        });
        return;
      }

      // ------------------------ IMAGE FLOW ------------------------
      final generatedPrompt = await _ds.startImageGeneration(
        ImageGenerationRequest(
          prompt: idea,
          style: "realistic",
          aspectRatio: _aspectForPlatform(video: false),
          brandPresets: _brand(),
          platform: _platform,
        ),
      );

      final renderTaskId = await _ds.startImageRender(
        promptUsed: generatedPrompt,
        style: "realistic",
        aspectRatio: _aspectForPlatform(video: false),
        platform: _platform,
      );

      final TaskStatus status = await _pollTaskUntilDone(
        renderTaskId,
        fetch: _ds.getImageStatus,
        timeout: const Duration(minutes: 5),
        interval: const Duration(seconds: 2),
      );

      final s = status.status.trim().toUpperCase();
      if (s == 'SUCCESS' || s == 'SUCCEEDED' || s == 'READY') {
        final url = status.url;
        if (url == null || url.isEmpty) throw Exception("Image success but no URL");
        setState(() {
          _captionCtrl.text = caption;
          _imageUrl = url;
          _loading = false;
        });
      } else {
        throw Exception(status.error ?? "Image render failed (status=$s)");
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = _extractError(e);
      });
    }
  }

  String _extractError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      return e.message ?? e.toString();
    }
    return e.toString();
  }

  Future<TaskStatus> _pollTaskUntilDone(
    String taskId, {
    required Future<TaskStatus> Function(String id) fetch,
    Duration timeout = const Duration(minutes: 10),
    Duration interval = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    TaskStatus status = await fetch(taskId);

    while (mounted) {
      final s = status.status.trim().toUpperCase();
      if (s == 'READY' || s == 'FAILED' || s == 'SUCCESS' || s == 'SUCCEEDED') break;
      if (DateTime.now().isAfter(deadline)) {
        throw Exception("Timed out waiting for task $taskId");
      }
      await Future.delayed(interval);
      status = await fetch(taskId);
    }
    return status;
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

    return Scaffold(
      appBar: AppBar(title: const Text('Create Content')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: const Color(0xFF0F2137),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.auto_awesome, color: Colors.white)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SocialSpark',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('AI-Powered Content Creation',
                        style:
                            TextStyle(color: Colors.black54, fontSize: 12)),
                  ]),
            ),
          ]),
          const SizedBox(height: 16),

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
              hintText: 'Describe your idea… (e.g. 15s TikTok for wildlife conservation ad)',
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
                  ? (_isVideoType ? 'Starting video…' : 'Generating…')
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

          if (!_loading &&
              (_captionCtrl.text.isNotEmpty || _imageUrl != null)) ...[
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
            const SizedBox(height: 12),

            // Image preview only for image flow
            if (!_isVideoType) ...[
              const Text('Preview',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_imageUrl != null && _imageUrl!.startsWith('http'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imageUrl!,
                    width: 260,
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgFallback(),
                  ),
                )
              else
                _imgFallback(),
            ],

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

          // VIDEO SECTION (auto-starts after pressing the top Generate)
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Video ready (task $taskId)')),
                );
              },
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.image, size: 48),
      );
}

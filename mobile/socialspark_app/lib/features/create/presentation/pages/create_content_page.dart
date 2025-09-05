import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_client.dart';
import '../../../create/data/datasources/create_remote_ds.dart';
import '../../../create/data/models/brand_preset.dart';
import '../../../create/data/models/requests.dart';
import '../../../create/data/models/task_status.dart';

class CreateContentPage extends StatefulWidget {
  const CreateContentPage({super.key});
  @override
  State<CreateContentPage> createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  late final CreateRemoteDataSource _ds;

  final _ideaCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _ds = CreateRemoteDataSource(ApiClient());
  }

  @override
  void dispose() {
    _ideaCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  BrandPreset _buildBrand() => BrandPreset(
        name: "SocialSpark Demo",
        colors: ["#003366", "#F9C51C", "#E74C3C"],
        tone: _tone,
        defaultHashtags: _hashtags,
        footerText: "Made with SocialSpark",
      );

  Future<void> _generateAll() async {
    setState(() {
      _loading = true;
      _error = null;
      _imageUrl = null;
    });

    final idea = _ideaCtrl.text.trim().isEmpty
        ? "Caramel Macadamia latte promo"
        : _ideaCtrl.text.trim();

    final isVideo = _ctype.contains('video') ||
        _ctype.contains('story') ||
        _ctype.contains('reel');

    try {
      // 1) Caption (backend expects `idea`)
      final caption = await _ds.generateCaption(
        CaptionRequest(
          idea: idea,
          brandPresets: _buildBrand(),
          platform: _platform,
        ),
      );

      String? previewUrl;

      if (isVideo) {
        // ---------- VIDEO FLOW ----------
        final storyboardTask = await _ds.startStoryboard({
          // backend expects `idea` for storyboard
          "idea": idea,
          "platform": _platform,
          "brand_presets": _buildBrand().toJson(),
        });

        // Render the storyboard → returns a render task id
        final renderTask = await _ds.startVideoRender({
          "task_id": storyboardTask,
        });

        // Poll status for the render task (reuse getImageStatus if server shares schema)
        var status = await _ds.getImageStatus(renderTask);
        final deadline = DateTime.now().add(const Duration(minutes: 5));
        while (mounted) {
          if (status.status == "succeeded" && status.url != null) break;
          if (status.status == "failed") {
            throw Exception(status.error ?? "Video failed");
          }
          if (DateTime.now().isAfter(deadline)) {
            throw Exception("Timed out waiting for video");
          }
          await Future.delayed(const Duration(seconds: 2));
          status = await _ds.getImageStatus(renderTask);
        }
        previewUrl = status.url; // likely .mp4 (you can show a video player later)
      } else {
       // ---------- IMAGE FLOW (generate prompt → render → poll) ----------
final generatedPrompt = await _ds.startImageGeneration(
  ImageGenerationRequest(
    prompt: idea, // images expect `prompt`
    style: "realistic",
    aspectRatio: _platform == 'tiktok' ? "9:16" : "1:1",
    brandPresets: _buildBrand(),
    platform: _platform,
  ),
);

// Use that prompt to start the render job -> returns TASK ID
final renderTaskId = await _ds.startImageRender(
  promptUsed: generatedPrompt,
  style: "realistic",
  aspectRatio: _platform == 'tiktok' ? "9:16" : "1:1",
  platform: _platform,
);

// Poll /status/{task_id}
var status = await _ds.getImageStatus(renderTaskId);
final deadline = DateTime.now().add(const Duration(minutes: 5));
while (mounted) {
  if (status.status == "succeeded" && status.url != null) break;
  if (status.status == "failed") {
    throw Exception(status.error ?? "Image render failed");
  }
  if (DateTime.now().isAfter(deadline)) {
    throw Exception("Timed out waiting for image");
  }
  await Future.delayed(const Duration(seconds: 2));
  status = await _ds.getImageStatus(renderTaskId);
}
final previewUrl = status.url;
 // ---------- IMAGE FLOW (two-step) ----------
      }

      setState(() {
        _captionCtrl.text = caption;
        _imageUrl = previewUrl;
        _loading = false;
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
              hintText: 'Describe your idea… (e.g. TikTok for my new latte)',
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
                onChanged: (v) =>
                    setState(() => _ctype = v ?? 'image post'),
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
              label: Text(_loading ? 'Generating…' : 'Generate'),
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

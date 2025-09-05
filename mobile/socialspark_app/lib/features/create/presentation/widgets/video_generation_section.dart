import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../create/data/datasources/create_remote_ds.dart';
import '../../../create/data/models/brand_preset.dart';
import '../../../create/data/models/task_status.dart';
// …imports stay the same…

class VideoGenerationSection extends StatefulWidget {
  const VideoGenerationSection({
    super.key,
    this.initialIdea,
    this.initialPlatform = 'instagram',
    this.initialCta = 'call and reserve',
    this.brandPreset,
    this.onVideoReady,
  });

  final String? initialIdea;
  final String initialPlatform;
  final String initialCta;
  final BrandPreset? brandPreset;
  final void Function(String videoUrl, String taskId)? onVideoReady;

  @override
  State<VideoGenerationSection> createState() => VideoGenerationSectionState();
}

class VideoGenerationSectionState extends State<VideoGenerationSection> {
  // --- everything you had stays the same up to _start() ---

  /// Public: trigger the whole flow.
  Future<void> start() => _start();

  // Send ANY storyboard (already in the exact schema) to /render/video and poll.
  Future<void> _renderStoryboard(Map<String, dynamic> storyboard) async {
    setState(() {
      _loading = true;
      _error = null;
      _videoUrl = null;
      _taskId = null;
    });

    try {
      // 1) render
      debugPrint('POST /render/video -> ${jsonEncode(storyboard)}');
      final renderResp = await _ds.startVideoRender(storyboard);
      final taskId = _extractTaskId(renderResp);
      _taskId = taskId;

      // 2) poll
      final status = await _pollTaskUntilDone(
        taskId,
        fetch: _ds.getTaskStatus,
        timeout: const Duration(minutes: 10),
        interval: const Duration(seconds: 2),
      );

      final s = status.status.trim().toUpperCase(); // QUEUED | READY | FAILED
      if (s == 'READY' && (status.url?.isNotEmpty ?? false)) {
        setState(() {
          _videoUrl = status.url;
          _loading = false;
        });
        widget.onVideoReady?.call(status.url!, taskId);
      } else if (s == 'FAILED') {
        throw Exception(status.error ?? 'Video task failed.');
      } else {
        throw Exception('Video not ready (status=$s).');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = _extractError(e);
      });
    }
  }

  Future<void> _start() async {
    if (!mounted || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
      _videoUrl = null;
      _taskId = null;
    });

    final idea = _ideaCtrl.text.trim().isEmpty
        ? '15s TikTok for wildlife conservation ad'
        : _ideaCtrl.text.trim();
    final cta = _ctaCtrl.text.trim().isEmpty ? 'call and reserve' : _ctaCtrl.text.trim();

    try {
      // 1) generate storyboard
      final sbBody = {
        "idea": idea,
        "language": "english",
        "number_of_shots": 5,
        "platform": _platform,
        "cta": cta,
        "brand_presets": _brandApi(),
      };
      debugPrint("POST /generate/storyboard -> ${jsonEncode(sbBody)}");

      final rawStoryboard = await _ds.startStoryboard(sbBody);

      // 2) pass AS-IS to render
      final storyboard = _toStoryboardMap(rawStoryboard); // shots+music exactly
      await _renderStoryboard(storyboard);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = _extractError(e);
      });
    }
  }

  // Accept Map or JSON string (no reshaping)
  Map<String, dynamic> _toStoryboardMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Storyboard must be an object with "shots" and "music".');
  }

  // --- everything else (helpers, UI) stays, plus the DEV button below ---

  @override
  Widget build(BuildContext context) {
    // your existing UI...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // … your inputs …

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.movie_creation_outlined),
            label: Text(_loading ? 'Generating…' : 'Generate Video'),
            onPressed: _loading ? null : _start,
          ),
        ),

        // --- DEV: render with a known storyboard JSON directly -------------
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _loading
              ? null
              : () {
                  const sample = {
                    "shots": [
                      {"duration": 4, "text": "Playful monkey"},
                      {"duration": 3, "text": "Cute panda"},
                      {"duration": 4, "text": "Majestic lion"},
                      {"duration": 3, "text": "Colorful parrot"},
                      {"duration": 5, "text": "Wildlife logo call to action"}
                    ],
                    "music": "upbeat"
                  };
                  _renderStoryboard(Map<String, dynamic>.from(sample));
                },
          icon: const Icon(Icons.science_outlined),
          label: const Text('Render sample storyboard'),
        ),
        // -------------------------------------------------------------------

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        if (_loading) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        if (!_loading && (_videoUrl != null || _taskId != null)) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Render status'),
                const SizedBox(height: 8),
                if (_videoUrl != null)
                  FilledButton.icon(
                    onPressed: () => _openUrl(_videoUrl!),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Open / Download video'),
                  )
                else
                  const Text('Task created, waiting for READY…'),
                if (_taskId != null) ...[
                  const SizedBox(height: 8),
                  Text('Task: $_taskId'),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

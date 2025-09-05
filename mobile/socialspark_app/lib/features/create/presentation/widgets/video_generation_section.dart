import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../create/data/datasources/create_remote_ds.dart';
import '../../../create/data/models/brand_preset.dart';
import '../../../create/data/models/task_status.dart';

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
  late final CreateRemoteDataSource _ds;

  final _ideaCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();

  final _platforms = const ['instagram', 'tiktok'];

  String _platform = 'instagram';
  String? _error;
  bool _loading = false;

  String? _videoUrl;
  String? _taskId;

  @override
  void initState() {
    super.initState();
    _ds = CreateRemoteDataSource(ApiClient());
    _platform = widget.initialPlatform;
    _ideaCtrl.text = widget.initialIdea?.trim().isNotEmpty == true
        ? widget.initialIdea!.trim()
        : '15s TikTok for wildlife conservation ad';
    _ctaCtrl.text = widget.initialCta;
  }

  @override
  void didUpdateWidget(covariant VideoGenerationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep fields in sync if parent changes them
    if (widget.initialIdea != oldWidget.initialIdea &&
        (widget.initialIdea ?? '').trim().isNotEmpty) {
      _ideaCtrl.text = widget.initialIdea!.trim();
    }
    if (widget.initialCta != oldWidget.initialCta &&
        (widget.initialCta).trim().isNotEmpty) {
      _ctaCtrl.text = widget.initialCta.trim();
    }
    if (widget.initialPlatform != oldWidget.initialPlatform &&
        widget.initialPlatform.isNotEmpty) {
      _platform = widget.initialPlatform;
    }
  }

  @override
  void dispose() {
    _ideaCtrl.dispose();
    _ctaCtrl.dispose();
    super.dispose();
  }

  BrandPreset _brand() =>
      widget.brandPreset ??
      const BrandPreset(
        name: "Wildlife",
        colors: ["#FBBF24", "#0D2A4B"],
        tone: "Playful",
        defaultHashtags: ["#Wildlife"],
        footerText: "Wildlife 2025",
      );

  Map<String, dynamic> _brandApi() => _brand().toApiJson();

  /// Public: allows parent to trigger the whole flow.
  Future<void> start() => _start();

  // ----------------------------- FLOW --------------------------------

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
      // 1) /generate/storyboard
      final Map<String, dynamic> storyboardBody = {
        "idea": idea,
        "language": "english",
        "number_of_shots": 5,
        "platform": _platform,
        "cta": cta,
        "brand_presets": _brandApi(),
      };
      debugPrint("POST /generate/storyboard -> ${jsonEncode(storyboardBody)}");

      final rawStoryboard = await _ds.startStoryboard(storyboardBody);

      // 2) Ensure it's a Map<String, dynamic> and sanitize
      final Map<String, dynamic> storyboard = _ensureStoryboardMap(rawStoryboard);

      final List<Map<String, dynamic>> shots = (storyboard['shots'] as List)
          .map<Map<String, dynamic>>(
            (s) => _sanitizeShot(Map<String, dynamic>.from(s as Map)),
          )
          .toList();

      final Map<String, dynamic> renderBody = <String, dynamic>{
        'shots': shots,
        'music': (storyboard['music'] ?? 'upbeat').toString(),
      };

      debugPrint('POST /render/video -> ${jsonEncode(renderBody)}');

      // 3) /render/video
      final renderResp = await _ds.startVideoRender(renderBody);
      final taskId = _extractTaskId(renderResp);
      _taskId = taskId;

      // 4) Poll /tasks/{id}
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
        if (widget.onVideoReady != null) {
          widget.onVideoReady!(status.url!, taskId);
        }
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

  // ----------------------------- HELPERS -----------------------------

  Map<String, dynamic> _ensureStoryboardMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return _sanitizeStoryboard(raw);
    if (raw is Map) return _sanitizeStoryboard(Map<String, dynamic>.from(raw));
    if (raw is String) {
      // Try strict JSON first
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return _sanitizeStoryboard(decoded);
        if (decoded is Map) {
          return _sanitizeStoryboard(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        // fallthrough to loose parsing
      }
      final loose = _parseLooseStoryboardString(raw);
      return _sanitizeStoryboard(loose);
    }
    throw Exception('Unsupported storyboard type: ${raw.runtimeType}');
  }

  Map<String, dynamic> _sanitizeStoryboard(Map<String, dynamic> m) {
    final List<Map<String, dynamic>> shots = ((m['shots'] ?? const []) as List)
        .map<Map<String, dynamic>>(
          (s) => _sanitizeShot(Map<String, dynamic>.from(s as Map)),
        )
        .toList();

    final String music = (m['music'] ?? 'upbeat').toString();
    return <String, dynamic>{'shots': shots, 'music': music};
  }

  Map<String, dynamic> _sanitizeShot(Map<String, dynamic> mm) {
    final durNum = mm['duration'];
    int duration;
    if (durNum is num) {
      duration = durNum.round();
    } else {
      duration = int.tryParse('${mm['duration']}') ?? 4;
    }
    final text = (mm['text'] ?? mm['caption'] ?? mm['title'] ?? '').toString();
    return <String, dynamic>{'duration': duration, 'text': text};
  }

  /// Lenient parser for pseudo-JSON like: {shots:[{duration:3,text:...},...], music:upbeat}
  Map<String, dynamic> _parseLooseStoryboardString(String s) {
    final List<Map<String, dynamic>> shots = <Map<String, dynamic>>[];

    // Normalize curly quotes
    final String txt = s
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201c', '"')
        .replaceAll('\u201d', '"');

    // Blocks like {duration: 3, text: Playful monkey}
    final RegExp blockRe = RegExp(r'\{[^{}]*\}');
    final RegExp durationRe =
        RegExp(r'(?:duration|duration_sec|len)\s*[:=-]\s*([0-9]+(?:\.[0-9]+)?)', caseSensitive: false);
    final RegExp textRe =
        RegExp(r'(?:text|caption|title)\s*[:=-]\s*([^,}\n]+)', caseSensitive: false);

    for (final m in blockRe.allMatches(txt)) {
      final block = m.group(0)!;
      final d = durationRe.firstMatch(block);
      final t = textRe.firstMatch(block);

      final dur = d != null ? double.tryParse(d.group(1)!) ?? 4.0 : 4.0;
      var text = t != null ? t.group(1)!.trim() : '';

      // strip surrounding quotes
      text = text.replaceAll(RegExp(r'''^["']|["']$'''), '').trim();

      if (text.isNotEmpty) {
        shots.add(<String, dynamic>{
          'duration': dur.round(), // ensure INT duration
          'text': text,
        });
      }
    }

    // music
    var music = 'upbeat';
    final RegExp musicRe =
        RegExp(r'music\s*[:=-]\s*("?)([A-Za-z0-9 _\-]+)\1', caseSensitive: false);
    final mm = musicRe.firstMatch(txt);
    if (mm != null) music = mm.group(2)!.trim();

    if (shots.isEmpty) {
      throw const FormatException('Could not parse storyboard shots');
    }
    return <String, dynamic>{'shots': shots, 'music': music};
  }

  String _extractTaskId(dynamic renderResponse) {
    if (renderResponse == null) {
      throw Exception('Empty /render/video response');
    }

    if (renderResponse is Map) {
      final m = Map<String, dynamic>.from(renderResponse);
      final id = (m['task_id'] ?? m['id'] ?? m['taskId'] ?? '').toString();
      if (id.isNotEmpty) return id;
    }
    if (renderResponse is String) {
      try {
        final m = jsonDecode(renderResponse);
        if (m is Map) {
          final id = (m['task_id'] ?? m['id'] ?? m['taskId'] ?? '').toString();
          if (id.isNotEmpty) return id;
        }
      } catch (_) {
        if (renderResponse.isNotEmpty) return renderResponse; // raw id string
      }
    }
    return renderResponse.toString();
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

  String _extractError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      return e.message ?? e.toString();
    }
    return e.toString();
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  // ----------------------------- UI ----------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Video generator',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _ideaCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Idea',
            hintText: 'e.g., 15s TikTok for wildlife conservation ad',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
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
                  labelText: 'CTA',
                  hintText: 'call and reserve',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.movie_creation_outlined),
            label: Text(_loading ? 'Generating…' : 'Generate Video'),
            onPressed: _loading ? null : _start,
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

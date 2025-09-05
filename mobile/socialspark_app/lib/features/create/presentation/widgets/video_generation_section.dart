import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Minimal API client that talks to your backend.
class SocialSparkApiClient {
  final Dio _dio;
  SocialSparkApiClient(String baseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
          headers: {"Content-Type": "application/json"},
        ));

  Future<dynamic> generateStoryboard({
    required String idea,
    String language = 'en',
    int numberOfShots = 6,
    String? platform,
    Map<String, dynamic>? brandPresets,
    String? cta,
  }) async {
    final body = {
      'idea': idea,
      'language': language,
      'number_of_shots': numberOfShots,
      if (platform != null && platform.isNotEmpty) 'platform': platform,
      if (brandPresets != null) 'brand_presets': brandPresets,
      if (cta != null && cta.isNotEmpty) 'cta': cta,
    };
    final res = await _dio.post('/generate/storyboard', data: body);
    return res.data;
  }

  Future<String> renderVideo({
    required dynamic storyboard, // string OR structured JSON
    String aspectRatio = '9:16',
    String resolution = '1080x1920',
    int fps = 30,
    String? platform,
    Map<String, dynamic>? brandPresets,
  }) async {
    final Map<String, dynamic> body = {
      'aspect_ratio': aspectRatio,
      'resolution': resolution,
      'fps': fps,
      if (platform != null && platform.isNotEmpty) 'platform': platform,
      if (brandPresets != null) 'brand_presets': brandPresets,
    };

    // Be flexible with whatever storyboard returns
    if (storyboard is String) {
      body['storyboard'] = storyboard;
    } else if (storyboard is List) {
      body['shots'] = storyboard; // e.g., list of shots
    } else if (storyboard is Map<String, dynamic>) {
      body.addAll(storyboard); // already structured
    } else {
      body['storyboard'] = storyboard.toString();
    }

    final res = await _dio.post('/render/video', data: body);
    final data = res.data;
    if (data is String) return data; // task id directly
    if (data is Map && data['task_id'] != null) return data['task_id'];
    if (data is Map && data['id'] != null) return data['id'];
    throw Exception('No task id in response');
  }

  Future<Map<String, dynamic>> getTask(String taskId) async {
    final res = await _dio.get('/tasks/$taskId');
    return Map<String, dynamic>.from(res.data);
  }
}

class VideoGenerationSection extends StatefulWidget {
  const VideoGenerationSection({
    super.key,
    required this.baseUrl,
    this.initialIdea = '',
  });

  final String baseUrl; // e.g. http://10.0.2.2:8000
  final String initialIdea;

  @override
  State<VideoGenerationSection> createState() => _VideoGenerationSectionState();
}

class _VideoGenerationSectionState extends State<VideoGenerationSection> {
  late final SocialSparkApiClient _api;

  // Form fields
  final _formKey = GlobalKey<FormState>();
  final _ideaCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();
  final _languageCtrl = TextEditingController(text: 'en');
  final _platformCtrl = TextEditingController(text: 'tiktok');
  final _footerTextCtrl = TextEditingController();
  final _hashtagsCtrl = TextEditingController(text: '#socialspark');
  int _shots = 6;

  // Storyboard + task state
  dynamic _storyboard;
  String? _taskId;
  Map<String, dynamic>? _taskData;
  Timer? _pollTimer;
  bool _isGeneratingStoryboard = false;
  bool _isRendering = false;

  @override
  void initState() {
    super.initState();
    _api = SocialSparkApiClient(widget.baseUrl);
    _ideaCtrl.text = widget.initialIdea;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _ideaCtrl.dispose();
    _ctaCtrl.dispose();
    _languageCtrl.dispose();
    _platformCtrl.dispose();
    _footerTextCtrl.dispose();
    _hashtagsCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _brandPresetsFromForm() {
    final hashtags = _hashtagsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return {
      'name': 'SocialSpark',
      'colors': ['#0ea5e9', '#111827'],
      'tone': 'energetic',
      'default_hashtags': hashtags,
      'footer_text': _footerTextCtrl.text.trim().isEmpty
          ? null
          : _footerTextCtrl.text.trim(),
    }..removeWhere((k, v) => v == null);
  }

  Future<void> _onGenerateStoryboard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isGeneratingStoryboard = true;
      _storyboard = null;
      _taskId = null;
      _taskData = null;
    });

    try {
      final sb = await _api.generateStoryboard(
        idea: _ideaCtrl.text.trim(),
        language: _languageCtrl.text.trim(),
        numberOfShots: _shots,
        platform: _platformCtrl.text.trim(),
        brandPresets: _brandPresetsFromForm(),
        cta: _ctaCtrl.text.trim().isEmpty ? null : _ctaCtrl.text.trim(),
      );
      setState(() => _storyboard = sb);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storyboard error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingStoryboard = false);
    }
  }

  Future<void> _onRenderVideo() async {
    if (_storyboard == null) return;
    setState(() {
      _isRendering = true;
      _taskData = null;
    });

    try {
      final tid = await _api.renderVideo(
        storyboard: _storyboard,
        aspectRatio: '9:16',
        resolution: '1080x1920',
        fps: 30,
        platform: _platformCtrl.text.trim(),
        brandPresets: _brandPresetsFromForm(),
      );
      setState(() => _taskId = tid);
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Render error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isRendering = false);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_taskId == null) return;
      try {
        final data = await _api.getTask(_taskId!);
        setState(() => _taskData = data);
        final status = (data['status'] ?? data['state'] ?? '').toString().toUpperCase();
        if (status == 'SUCCESS' || status == 'FAILED' || status == 'FAILURE' || status == 'ERROR') {
          _pollTimer?.cancel();
        }
      } catch (_) {}
    });
  }

  Future<void> _openVideo() async {
    final url = _taskData?['video_url'] ?? _taskData?['url'] ?? _taskData?['result'];
    if (url is String && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open video URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.movie_creation_outlined),
                const SizedBox(width: 8),
                Text('Generate Video', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (_taskId != null)
                  Chip(
                    label: Text('Task: ${_taskId!.substring(0, _taskId!.length.clamp(0, 8))}…'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // FORM
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _ideaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Idea / Topic',
                      hintText: 'e.g., 3 tips to grow your brand',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter an idea' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _languageCtrl,
                        decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _platformCtrl,
                        decoration: const InputDecoration(labelText: 'Platform', hintText: 'tiktok / reels / shorts', border: OutlineInputBorder()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _shots,
                        decoration: const InputDecoration(labelText: 'Number of shots', border: OutlineInputBorder()),
                        items: const [4, 5, 6, 7, 8, 9, 10]
                            .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                            .toList(),
                        onChanged: (v) => setState(() => _shots = v ?? 6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _ctaCtrl,
                        decoration: const InputDecoration(labelText: 'CTA (optional)', border: OutlineInputBorder()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _footerTextCtrl,
                        decoration: const InputDecoration(labelText: 'Footer (@brand, optional)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _hashtagsCtrl,
                        decoration: const InputDecoration(labelText: 'Hashtags (comma separated)', border: OutlineInputBorder()),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _isGeneratingStoryboard ? null : _onGenerateStoryboard,
                  icon: _isGeneratingStoryboard
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_stories_outlined),
                  label: const Text('Generate Storyboard'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: (_storyboard != null && !_isRendering) ? _onRenderVideo : null,
                  icon: _isRendering
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.mode_edit_outlined),
                  label: const Text('Render Video'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Storyboard preview
            if (_storyboard != null) ...[
              Text('Storyboard preview', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(_storyboard),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Task status
            if (_taskId != null) ...[
              Row(
                children: [
                  const Icon(Icons.timelapse_outlined),
                  const SizedBox(width: 8),
                  Text('Task status', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: $_taskId'),
                    const SizedBox(height: 6),
                    Text('Status: ' + ((_taskData?['status'] ?? _taskData?['state'] ?? 'PENDING').toString())),
                    if (_taskData?['progress'] != null) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: (_taskData!['progress'] as num).toDouble().clamp(0, 1)),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            if (_taskId == null) return;
                            final data = await _api.getTask(_taskId!);
                            setState(() => _taskData = data);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                        const SizedBox(width: 12),
                        if (((_taskData?['status'] ?? _taskData?['state'])?.toString().toUpperCase() == 'SUCCESS') &&
                            ((_taskData?['video_url'] ?? _taskData?['url'] ?? _taskData?['result']) != null))
                          FilledButton.icon(
                            onPressed: _openVideo,
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Open / Download video'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

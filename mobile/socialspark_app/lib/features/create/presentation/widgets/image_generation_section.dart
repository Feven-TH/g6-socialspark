
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/create_remote_ds.dart';
import '../../data/models/brand_preset.dart';
import '../../data/models/requests.dart';
import '../../data/models/task_status.dart';

class ImageGenerationSection extends StatefulWidget {
  const ImageGenerationSection({
    super.key,
    required this.initialIdea,
    required this.initialPlatform,
    required this.brandPreset,
    this.onImageReady,
  });

  final String initialIdea;
  final String initialPlatform;
  final BrandPreset brandPreset;
  final void Function(String url, String taskId)? onImageReady;

  @override
  State<ImageGenerationSection> createState() => ImageGenerationSectionState();
}

class ImageGenerationSectionState extends State<ImageGenerationSection> {
  late final CreateRemoteDataSource _ds;

  String? _taskId;
  TaskStatus? _status;
  String? _error;
  bool _loading = false;

  String get _aspectRatio => widget.initialPlatform == 'tiktok' ? '9:16' : '1:1';

  @override
  void initState() {
    super.initState();
    _ds = CreateRemoteDataSource(ApiClient());
  }

  Future<void> start() async {
    setState(() {
      _loading = true;
      _error = null;
      _status = null;
      _taskId = null;
    });

    try {
      final generatedPrompt = await _ds.startImageGeneration(
        ImageGenerationRequest(
          prompt: widget.initialIdea,
          style: 'realistic',
          aspectRatio: _aspectRatio,
          brandPresets: widget.brandPreset,
          platform: widget.initialPlatform,
        ),
      );

      final renderTaskId = await _ds.startImageRender(
        promptUsed: generatedPrompt,
        style: 'realistic',
        aspectRatio: _aspectRatio,
        platform: widget.initialPlatform,
      );

      setState(() => _taskId = renderTaskId);
      _pollStatus();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pollStatus() async {
    if (_taskId == null) return;

    final status = await _pollTaskUntilDone(
      _taskId!,
      fetch: _ds.getImageStatus,
      timeout: const Duration(minutes: 5),
      interval: const Duration(seconds: 2),
    );

    setState(() {
      _status = status;
      _loading = false;
    });

    final s = status.status.trim().toUpperCase();
    if (s == 'SUCCESS' || s == 'SUCCEEDED' || s == 'READY' || s == 'COMPLETED') {
      final url = status.url;
      if (url != null && url.isNotEmpty) {
        widget.onImageReady?.call(url, _taskId!);
      } else {
        setState(() => _error = 'Image success but no URL. Response: ${status.toString()}');
      }
    } else {
      setState(() => _error = status.error ?? 'Image render failed (status=$s)');
    }
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
      if (s == 'READY' || s == 'FAILED' || s == 'SUCCESS' || s == 'SUCCEEDED' || s == 'COMPLETED') break;
      if (DateTime.now().isAfter(deadline)) {
        throw Exception('Timed out waiting for task $taskId');
      }
      await Future.delayed(interval);
      status = await fetch(taskId);
      setState(() => _status = status);
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final url = status?.url;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
        if (status != null) ...[
          const SizedBox(height: 12),
          Text('Status: ${status.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (url != null && url.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 260,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imgFallback(),
              ),
            )
          else if (status.status.toLowerCase() != 'completed')
            _imgFallback(),
        ],
      ],
    );
  }

  Widget _imgFallback() => Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image, size: 48),
      );
}

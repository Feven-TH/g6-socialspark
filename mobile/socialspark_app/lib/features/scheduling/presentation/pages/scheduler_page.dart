import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../library/data/models/library_item.dart';
import '../../../editor/domain/entities/content.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({
    super.key,
    required this.mediaUrl,
    required this.caption,
    required this.platform,
    required this.type,
  });

  // Convenience ctor for Library -> Scheduler
  factory SchedulerPage.fromLibraryItem({required LibraryItem item}) {
    return SchedulerPage(
      mediaUrl: item.mediaUrl,
      caption: item.caption,
      platform: item.platform,
      type: item.type,
    );
  }

  final String mediaUrl;
  final String caption;
  final String platform;
  final MediaType type;

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 11, minute: 23);

  VideoPlayerController? _videoCtl;
  Future<void>? _videoInit;
  String? _videoError;

  bool get _isVideo {
    final u = widget.mediaUrl.toLowerCase();
    return widget.type == MediaType.video ||
        u.endsWith('.mp4') ||
        u.endsWith('.mov') ||
        u.endsWith('.m3u8') ||
        u.contains('video');
  }

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      try {
        _videoCtl = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl))
          ..setLooping(true)
          ..setVolume(1.0);
        _videoInit = _videoCtl!.initialize().then((_) {
          if (mounted) setState(() {});
        }).catchError((e) {
          if (mounted) setState(() => _videoError = e.toString());
        });
        _videoCtl!.addListener(() {
          if (mounted) setState(() {}); // refresh overlay play/pause icon
        });
      } catch (e) {
        _videoError = e.toString();
      }
    }
  }

  @override
  void dispose() {
    _videoCtl?.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _download() async {
    // For demo we just open the media URL; replace with real download if needed
    final uri = Uri.parse(widget.mediaUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2137),
        foregroundColor: Colors.white,
        title: const Text('Schedule Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                widget.platform,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PREVIEW
          _PreviewCard(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: _isVideo
                    ? (_videoCtl?.value.isInitialized ?? false)
                        ? _videoCtl!.value.aspectRatio
                        : 16 / 9
                    : 16 / 9,
                child: _isVideo ? _buildVideo() : _buildImage(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // DETAILS
          _PreviewCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Post Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(
                    widget.caption,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FieldButton(
                          icon: Icons.event,
                          label: 'Date',
                          value:
                              '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FieldButton(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: _time.format(context),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ACTIONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _download,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DBE60),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo: posting now…'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Post Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8CFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              final scheduled = DateTime(
                _date.year,
                _date.month,
                _date.day,
                _time.hour,
                _time.minute,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scheduled for $scheduled')),
              );
            },
            icon: const Icon(Icons.schedule),
            label: const Text('Schedule Post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F2137),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // --------- preview builders ----------

  Widget _buildImage() {
    return Image.network(
      widget.mediaUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, size: 42, color: Colors.black45),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_videoError != null) {
      return _VideoErrorFallback(
        error: _videoError!,
        url: widget.mediaUrl,
      );
    }

    if (_videoCtl == null) {
      return _loadingShimmer();
    }

    return FutureBuilder(
      future: _videoInit,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _loadingShimmer();
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoCtl!),
            _PlayOverlay(controller: _videoCtl!),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: VideoProgressIndicator(
                _videoCtl!,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _loadingShimmer() => Container(
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
}

// ------------------ UI helpers ------------------

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.expand_more, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _PlayOverlay extends StatelessWidget {
  const _PlayOverlay({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.value.isPlaying;
    return GestureDetector(
      onTap: () => isPlaying ? controller.pause() : controller.play(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: isPlaying
            ? const SizedBox.shrink()
            : Container(
                key: const ValueKey('overlay'),
                color: Colors.black26,
                child: const Icon(Icons.play_circle, size: 72, color: Colors.white),
              ),
      ),
    );
  }
}

class _VideoErrorFallback extends StatelessWidget {
  const _VideoErrorFallback({required this.error, required this.url});
  final String error;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, size: 40, color: Colors.black54),
            const SizedBox(height: 8),
            const Text('Video preview failed'),
            const SizedBox(height: 4),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in browser'),
            ),
          ],
        ),
      ),
    );
  }
}

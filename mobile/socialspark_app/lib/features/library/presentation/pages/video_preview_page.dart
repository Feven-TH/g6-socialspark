import 'package:flutter/material.dart';
import 'package:socialspark_app/core/widgets/video_player_box.dart';

class VideoPreviewPage extends StatelessWidget {
  const VideoPreviewPage({super.key, required this.url, this.caption = ''});

  final String url;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoPlayerBox(url: url, autoPlay: true),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(caption),
          ],
        ],
      ),
    );
  }
}

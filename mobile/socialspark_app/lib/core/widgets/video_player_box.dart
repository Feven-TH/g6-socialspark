import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerBox extends StatefulWidget {
  const VideoPlayerBox({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.loop = true,
    this.aspectRatioFallback = 16 / 9,
  });

  final String url;
  final bool autoPlay;
  final bool loop;
  final double aspectRatioFallback;

  @override
  State<VideoPlayerBox> createState() => _VideoPlayerBoxState();
}

class _VideoPlayerBoxState extends State<VideoPlayerBox>
    with WidgetsBindingObserver {
  VideoPlayerController? _video;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    // Newer video_player uses .networkUrl(Uri)
    try {
      final controller = kIsWeb
          ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
          : VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await controller.initialize();

      controller.setLooping(widget.loop);
      if (widget.autoPlay) controller.play();

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: widget.autoPlay,
        looping: widget.loop,
        allowMuting: true,
        allowFullScreen: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          backgroundColor: Colors.black26,
          bufferedColor: Colors.white24,
        ),
      );

      setState(() {
        _video = controller;
        _chewie = chewie;
      });
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_video == null) return;
    if (state == AppLifecycleState.paused) {
      _video!.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _video?.value.isInitialized == true
        ? _video!.value.aspectRatio
        : widget.aspectRatioFallback;

    return AspectRatio(
      aspectRatio: aspect,
      child: _chewie == null
          ? Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            )
          : Chewie(controller: _chewie!),
    );
  }
}

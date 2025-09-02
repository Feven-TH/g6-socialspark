import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../domain/entities/scheduled_post.dart';
import '../../domain/usecases/schedule_post.dart';
import '../../domain/usecases/share_now.dart';

class SchedulerPage extends StatefulWidget {
  final String contentPath;
  final String caption;
  final String platform;
  final ShareNow shareNow;
  final SchedulePost schedulePost;

  const SchedulerPage({
    Key? key,
    required this.contentPath,
    required this.caption,
    required this.platform,
    required this.shareNow,
    required this.schedulePost,
  }) : super(key: key);

  @override
  _SchedulerPageState createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();

  void _postNow() async {
    try {
      await widget.shareNow(widget.contentPath, widget.caption);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content shared successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  void _schedulePost() async {
    final scheduledTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    final post = ScheduledPost(
      contentPath: widget.contentPath,
      caption: widget.caption,
      platform: widget.platform,
      scheduledTime: scheduledTime,
    );

    try {
      await widget.schedulePost(post);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post scheduled for $scheduledTime!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish & Schedule'),
        backgroundColor: const Color(0xFF0D2A4B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(widget.contentPath, fit: BoxFit.cover)
                    : Image.file(File(widget.contentPath), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _postNow,
              child: Text(kIsWeb ? "Download Content" : "Post Now"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _scheduledDate = date);
              },
              child: Text("Date: ${_scheduledDate.toLocal()}".split(' ')[0]),
            ),
            OutlinedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _scheduledTime,
                );
                if (time != null) setState(() => _scheduledTime = time);
              },
              child: Text("Time: ${_scheduledTime.format(context)}"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _schedulePost,
              child: const Text("Schedule Post"),
            ),
          ],
        ),
      ),
    );
  }
}

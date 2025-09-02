import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For fetching web content
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/notification_service.dart';

class SchedulerPage extends StatefulWidget {
  final String contentPath;
  final String caption;
  final String platform;

  const SchedulerPage({
    Key? key,
    required this.contentPath,
    required this.caption,
    required this.platform,
  }) : super(key: key);

  @override
  _SchedulerPageState createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();

  final notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    notificationService.initNotification();
  }

  // Handle the 'Post Now' action
  void _postNow() async {
    if (kIsWeb) {
      await _downloadFileForWeb();
    } else {
      await _exportAndShare();
    }
  }

  // Handle the 'Schedule' action
  void _schedulePost() async {
    final finalScheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    if (finalScheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future time.')),
      );
      return;
    }

    await notificationService.scheduleNotification(
      id: 0,
      title: 'Time to Post!',
      body: 'Your post for ${widget.platform} is ready. Tap to share.',
      scheduledTime: finalScheduledDateTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post scheduled for ${finalScheduledDateTime.toString()}!')),
    );
  }

  // Fallback method to export and open the native share sheet
  Future<void> _exportAndShare() async {
    final file = File(widget.contentPath);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found.')),
      );
      return;
    }

    try {
      await Share.shareXFiles([XFile(widget.contentPath)], text: widget.caption);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content prepared! Now paste your caption.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  // Web-specific download logic
  Future<void> _downloadFileForWeb() async {
    try {
      final bytes = await http.readBytes(Uri.parse(widget.contentPath));
      final blob = createBlob(bytes);
      downloadBlob(blob, 'social_spark_content.png');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content downloaded. You can now post it manually.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download: $e')),
      );
    }
  }

  dynamic createBlob(List<int> bytes) {
    throw UnsupportedError('This method is not supported on this platform.');
  }

  void downloadBlob(dynamic blob, String fileName) {
    throw UnsupportedError('This method is not supported on this platform.');
  }

  // UI for selecting the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _scheduledDate) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  // UI for selecting the time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null && picked != _scheduledTime) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Publish & Schedule'),
        backgroundColor: const Color(0xFF0D2A4B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Content Preview
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          'https://via.placeholder.com/400x400.png?text=Content+Preview',
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(widget.contentPath),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Post Now Section
              ElevatedButton(
                onPressed: _postNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2A4B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  kIsWeb ? 'Download Content' : 'Post Now to ${widget.platform}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Or, Schedule for Later',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2A4B),
                ),
              ),
              const SizedBox(height: 16),
              
              // Date and Time Pickers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D2A4B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Date: ${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectTime(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D2A4B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Time: ${_scheduledTime.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Schedule Button
              ElevatedButton(
                onPressed: _schedulePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2A4B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Schedule Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

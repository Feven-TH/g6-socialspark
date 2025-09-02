import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/scheduled_post.dart';
import '../../domain/repositories/scheduler_repository.dart';

class SchedulerRepositoryImpl implements SchedulerRepository {
  final NotificationService notificationService;

  SchedulerRepositoryImpl(this.notificationService);

  @override
  Future<void> shareNow(String contentPath, String caption) async {
    if (kIsWeb) {
      final bytes = await http.readBytes(Uri.parse(contentPath));
      // In real web, implement JS interop for blob & download
      throw UnimplementedError("Web share not implemented yet");
    } else {
      final file = File(contentPath);
      if (!await file.exists()) throw Exception("File not found");
      await Share.shareXFiles([XFile(contentPath)], text: caption);
    }
  }

  @override
  Future<void> schedulePost(ScheduledPost post) async {
    if (post.scheduledTime.isBefore(DateTime.now())) {
      throw Exception("Scheduled time must be in the future");
    }

    await notificationService.scheduleNotification(
      id: 0,
      title: "Time to Post!",
      body: "Your post for ${post.platform} is ready. Tap to share.",
      scheduledTime: post.scheduledTime,
    );
  }
}

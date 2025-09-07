import '../entities/scheduled_post.dart';

abstract class SchedulerRepository {
  Future<void> shareNow(String contentPath, String caption);
  Future<void> schedulePost(ScheduledPost post);
}

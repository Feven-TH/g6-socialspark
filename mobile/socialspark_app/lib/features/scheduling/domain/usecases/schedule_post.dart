import '../entities/scheduled_post.dart';
import '../repositories/scheduler_repository.dart';

class SchedulePost {
  final SchedulerRepository repository;

  SchedulePost(this.repository);

  Future<void> call(ScheduledPost post) {
    return repository.schedulePost(post);
  }
}

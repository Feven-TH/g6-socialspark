import '../repositories/scheduler_repository.dart';

class ShareNow {
  final SchedulerRepository repository;

  ShareNow(this.repository);

  Future<void> call(String contentPath, String caption) {
    return repository.shareNow(contentPath, caption);
  }
}

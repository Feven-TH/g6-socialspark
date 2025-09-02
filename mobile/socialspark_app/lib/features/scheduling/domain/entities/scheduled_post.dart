class ScheduledPost {
  final String contentPath;
  final String caption;
  final String platform;
  final DateTime scheduledTime;

  ScheduledPost({
    required this.contentPath,
    required this.caption,
    required this.platform,
    required this.scheduledTime,
  });
}

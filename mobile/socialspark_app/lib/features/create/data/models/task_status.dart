// mobile/socialspark_app/lib/features/create/data/models/task_status.dart
import 'package:equatable/equatable.dart';

class TaskStatus extends Equatable {
  const TaskStatus({
    required this.id,
    required this.status,
    this.url,
    this.error,
  });

  final String id;
  final String status; // queued | ready | failed | success | succeeded | processing | ...
  final String? url;   // video_url for video, image_url/url for image
  final String? error;

  // ---------- Convenience checks ----------
  bool get isQueued => _eq(status, 'queued') || _eq(status, 'processing') || _eq(status, 'running');
  bool get isReady  => _eq(status, 'ready');
  bool get isFailed => _eq(status, 'failed') || _eq(status, 'failure') || _eq(status, 'error');
  bool get isSuccess =>
      _eq(status, 'success') || _eq(status, 'succeeded') || _eq(status, 'ready');

  // ---------- Factories for different endpoints ----------
  /// Normalize GET /tasks/{id} response
  /// Expected: { status: queued|ready|failed, video_url?: string, error?: string }
  factory TaskStatus.fromTasksEndpoint(String id, Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString();
    final url = (json['video_url'] ?? json['url'])?.toString();
    final error = json['error']?.toString();
    return TaskStatus(id: id, status: status, url: url, error: error);
    }

  /// Normalize GET /status/{id} response (image flow)
  /// Expected: { status: processing|success|failed, image_url?: string, url?: string, error?: string }
  factory TaskStatus.fromImageStatus(String id, Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString();
    final url = (json['image_url'] ?? json['url'])?.toString();
    final error = json['error']?.toString();
    return TaskStatus(id: id, status: status, url: url, error: error);
  }

  @override
  List<Object?> get props => [id, status, url, error];

  @override
  String toString() => 'TaskStatus(id: $id, status: $status, url: $url, error: $error)';

  static bool _eq(String a, String b) => a.trim().toLowerCase() == b;
}

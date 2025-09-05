class TaskStatus {
  final String id;
  final String status; // queued|running|succeeded|failed
  final String? url;
  final String? error;

  TaskStatus({required this.id, required this.status, this.url, this.error});

  factory TaskStatus.fromJson(Map<String, dynamic> json) => TaskStatus(
    id: (json["id"] ?? json["task_id"] ?? "").toString(),
    status: (json["status"] ?? "").toString(),
    url: json["url"]?.toString(),
    error: json["error"]?.toString(),
  );
}

import '../../../../core/network/api_client.dart';
import '../models/requests.dart';
import '../models/task_status.dart';

class CreateRemoteDataSource {
  final ApiClient _api;
  CreateRemoteDataSource(this._api);

  // ---- Captions (expects `idea`) ----
  Future<String> generateCaption(CaptionRequest req) async {
    final res = await _api.post("/generate/caption", req.toJson());
    if (res is String) return res;
    if (res is Map && res["caption"] != null) return res["caption"].toString();
    return res.toString();
  }

  // ---- Images ----
  /// Step 1: returns the PROMPT string the server generated
  Future<String> startImageGeneration(ImageGenerationRequest req) async {
    final res = await _api.post("/generate/image", req.toJson());
    // Spec says it returns a string → that is the prompt to use next
    if (res is String) return res;
    return res.toString();
  }

  /// Step 2: send prompt_used + style/aspect/platform → returns TASK ID string
  Future<String> startImageRender({
    required String promptUsed,
    required String style,
    required String aspectRatio,
    required String platform,
  }) async {
    final body = {
      "prompt_used": promptUsed,
      "style": style,
      "aspect_ratio": aspectRatio,
      "platform": platform,
    };
    final res = await _api.post("/render/image", body);
    if (res is String) return res; // task id
    if (res is Map && (res["task_id"] != null || res["id"] != null)) {
      return (res["task_id"] ?? res["id"]).toString();
    }
    return res.toString();
  }

  /// Step 3: poll status. API returns a string; interpret smartly.
  Future<TaskStatus> getImageStatus(String taskId) async {
    final res = await _api.get("/status/$taskId");
    if (res is String) {
      final s = res.trim();
      if (s.startsWith("http")) {
        return TaskStatus(id: taskId, status: "succeeded", url: s);
      }
      // queued | running | failed | etc.
      return TaskStatus(id: taskId, status: s);
    }
    if (res is Map<String, dynamic>) return TaskStatus.fromJson(res);
    return TaskStatus(id: taskId, status: res.toString());
  }

  // ---- Videos (unchanged) ----
  Future<String> startStoryboard(Map<String, dynamic> body) async {
    final res = await _api.post("/generate/storyboard", body);
    if (res is String) return res;
    if (res is Map && (res["task_id"] != null || res["id"] != null)) {
      return (res["task_id"] ?? res["id"]).toString();
    }
    return res.toString();
  }

  Future<String> startVideoRender(Map<String, dynamic> body) async {
    final res = await _api.post("/render/video", body);
    if (res is String) return res;
    if (res is Map && (res["task_id"] != null || res["id"] != null)) {
      return (res["task_id"] ?? res["id"]).toString();
    }
    return res.toString();
  }
}

import '../../../../core/network/api_client.dart';
import '../models/requests.dart';
import '../models/task_status.dart';

class CreateRemoteDataSource {
  final ApiClient _api;
  CreateRemoteDataSource(this._api);

  // ---------------- CAPTIONS ----------------
  // POST /generate/caption  (expects `idea`)
  Future<String> generateCaption(CaptionRequest req) async {
    final res = await _api.post("/generate/caption", req.toJson());
    if (res is String) return res;
    if (res is Map && res["caption"] != null) return res["caption"].toString();
    return res.toString();
  }

  // ---------------- IMAGES ----------------
  // STEP 1: POST /generate/image  -> returns a PROMPT string
  Future<String> generateImagePrompt(ImageGenerationRequest req) async {
    final res = await _api.post("/generate/image", req.toJson());
    // Spec: response is a plain string (the finalized prompt).
    if (res is String) return res;
    // If backend ever wraps it, fallback:
    if (res is Map && res["prompt"] != null) return res["prompt"].toString();
    return res.toString();
  }

  // (Back-compat alias if you already call startImageGeneration elsewhere)
  @Deprecated('Use generateImagePrompt(...)')
  Future<String> startImageGeneration(ImageGenerationRequest req) =>
      generateImagePrompt(req);

  // STEP 2: POST /render/image  -> returns a TASK ID string
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
    if (res is String) return res; // task id (per spec)
    if (res is Map && (res["task_id"] != null || res["id"] != null)) {
      return (res["task_id"] ?? res["id"]).toString();
    }
    return res.toString();
  }

  // STEP 3: GET /status/{task_id}  -> may return a URL string or a status string/JSON
  Future<TaskStatus> getImageStatus(String taskId) async {
    final res = await _api.get("/status/$taskId");

    // Most common: server returns a plain string
    if (res is String) {
      final s = res.trim();
      if (s.startsWith('http')) {
        return TaskStatus(id: taskId, status: 'succeeded', url: s);
      }
      // queued | running | failed | succeeded
      return TaskStatus(id: taskId, status: s);
    }

    if (res is Map<String, dynamic>) {
      // If your backend later returns {status: "...", url: "..."} etc.
      return TaskStatus.fromJson(res);
    }

    // Fallback
    return TaskStatus(id: taskId, status: res.toString());
  }

  // ---------------- VIDEOS (placeholder; keep if you already call them) ----------------
  // POST /generate/storyboard
  Future<String> startStoryboard(Map<String, dynamic> body) async {
    final res = await _api.post("/generate/storyboard", body);
    if (res is String) return res;
    if (res is Map && (res["task_id"] != null || res["id"] != null)) {
      return (res["task_id"] ?? res["id"]).toString();
    }
    return res.toString();
  }

  // POST /render/video
  // Swagger shows it expects { shots: [{duration, text}], music }
  // (You can adjust the body you pass in your UI to match that.)
  Future<String> startVideoRender(Map<String, dynamic> body) async {
    final res = await _api.post("/render/video", body);
    if (res is String) return res;
    if (res is Map && (res["task_id"] != null || res["id"] != null)) {
      return (res["task_id"] ?? res["id"]).toString();
    }
    return res.toString();
  }
}

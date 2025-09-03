export interface BrandPresets {
  name: string;
  tone?: string;
  colors?: string[];
  default_hashtags?: string[];
  footer_text?: string;
}

export interface GenerateCaptionRequest {
  idea: string;
  language?: string;
  platform: string;
  hashtags_count?: number;
  brand_presets?: BrandPresets;
}

export interface GenerateCaptionResponse {
  caption: string;
  hashtags: string[];
}

export interface GenerateImageRequest {
  idea: string;
  aspect_ratio?: string;
  brand_presets?: BrandPresets;
}

export interface GenerateImageResponse {
  image_url: string;
}

export interface GenerateStoryboardRequest {
  idea: string;
  brand_presets?: BrandPresets;
  language?: string;
  number_of_shots?: number;
  platform: string;
  cta?: string;
}

export interface StoryboardShot {
  duration: number;
  text: string;
}

export interface GenerateStoryboardResponse {
  shots: StoryboardShot[];
  music: string;
}

export interface RenderVideoRequest {
  shots: StoryboardShot[];
  music: string;
}

export interface RenderVideoResponse {
  task_id: string;
  status: "queued" | "ready" | "failed";
}

export interface GetTaskResponse {
  status: "queued" | "processing" | "ready" | "failed";
  video_url?: string;
}

export interface ExportRequest {
  draft_id: string;
}

export interface ExportResponse {
  draft_id: string;
  asset_url: string;
}

export interface ScheduleRequest {
  asset_id: string;
  platform: string;
  run_at: string;
}

export interface ScheduleResponse {
  status: "queued" | "failed";
  scheduled_for: string;
  mode?: "api";
  platform_post_id?: string;
}

export interface ApiError {
  error: string;
  message: string;
}

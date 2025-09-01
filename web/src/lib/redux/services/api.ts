import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import type {
  GenerateCaptionRequest,
  GenerateCaptionResponse,
  GenerateImageRequest,
  GenerateImageResponse,
  GenerateStoryboardRequest,
  GenerateStoryboardResponse,
  RenderVideoRequest,
  RenderVideoResponse,
  GetTaskResponse,
  ExportRequest,
  ExportResponse,
  ScheduleRequest,
  ScheduleResponse,
} from "../../types/api";

export const socialSparkApi = createApi({
  reducerPath: "socialSparkApi",
  baseQuery: fetchBaseQuery({ baseUrl: "http://localhost:8000" }),
  tagTypes: ["Draft", "Task"],

  endpoints: (builder) => ({
    generateCaption: builder.mutation<
      GenerateCaptionResponse,
      GenerateCaptionRequest
    >({
      query: (body) => ({
        url: "/generate/caption",
        method: "POST",
        body,
      }),
    }),

    generateImage: builder.mutation<
      GenerateImageResponse,
      GenerateImageRequest
    >({
      query: (body) => ({
        url: "/generate/image",
        method: "POST",
        body,
      }),
    }),

    generateStoryboard: builder.mutation<
      GenerateStoryboardResponse,
      GenerateStoryboardRequest
    >({
      query: (body) => ({
        url: "/generate/storyboard",
        method: "POST",
        body,
      }),
    }),

    renderVideo: builder.mutation<RenderVideoResponse, RenderVideoRequest>({
      query: (body) => ({
        url: "/render/video",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Task"],
    }),

    getTask: builder.query<GetTaskResponse, string>({
      query: (taskId) => `/tasks/${taskId}`,
      providesTags: ["Task"],
    }),

    // 5. Export draft
    exportDraft: builder.mutation<ExportResponse, ExportRequest>({
      query: (body) => ({
        url: "/export",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Draft"],
    }),

    schedulePost: builder.mutation<ScheduleResponse, ScheduleRequest>({
      query: (body) => ({
        url: "/schedule",
        method: "POST",
        body,
      }),
    }),
  }),
});

export const {
  useGenerateCaptionMutation,
  useGenerateImageMutation,
  useGenerateStoryboardMutation,
  useRenderVideoMutation,
  useGetTaskQuery,
  useExportDraftMutation,
  useSchedulePostMutation,
} = socialSparkApi;

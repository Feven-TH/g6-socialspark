// API utilities for SocialSpark backend integration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000"

export interface GenerateCaptionResponse {
  caption: string
  hashtags: string[]
}

export interface GenerateImageResponse {
  image_url: string
}

export interface GenerateStoryboardResponse {
  shots: Array<{
    id: string
    description: string
    duration: number
    transition?: string
  }>
}

export interface RenderVideoResponse {
  task_id: string
}

export interface TaskStatusResponse {
  status: "pending" | "processing" | "completed" | "failed"
  video_url?: string
  error?: string
}

export interface ExportResponse {
  download_url: string
  format: string
  size: number
}

export interface ScheduleResponse {
  scheduled_id: string
  scheduled_time: string
  status: "scheduled" | "failed"
}

// API functions
export async function generateCaption(
  prompt: string,
  businessType?: string,
  language?: string,
): Promise<GenerateCaptionResponse> {
  const response = await fetch(`${API_BASE_URL}/generate/caption`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      prompt,
      business_type: businessType,
      language: language || "en",
    }),
  })

  if (!response.ok) {
    throw new Error(`Failed to generate caption: ${response.statusText}`)
  }

  return response.json()
}

export async function generateImage(prompt: string, style?: string): Promise<GenerateImageResponse> {
  const response = await fetch(`${API_BASE_URL}/generate/image`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      prompt,
      style: style || "realistic",
    }),
  })

  if (!response.ok) {
    throw new Error(`Failed to generate image: ${response.statusText}`)
  }

  return response.json()
}

export async function generateStoryboard(prompt: string, duration?: number): Promise<GenerateStoryboardResponse> {
  const response = await fetch(`${API_BASE_URL}/generate/storyboard`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      prompt,
      duration: duration || 15,
    }),
  })

  if (!response.ok) {
    throw new Error(`Failed to generate storyboard: ${response.statusText}`)
  }

  return response.json()
}

export async function renderVideo(storyboard: string[], audio?: string): Promise<RenderVideoResponse> {
  const response = await fetch(`${API_BASE_URL}/render/video`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      storyboard,
      audio,
    }),
  })

  if (!response.ok) {
    throw new Error(`Failed to start video rendering: ${response.statusText}`)
  }

  return response.json()
}

export async function getTaskStatus(taskId: string): Promise<TaskStatusResponse> {
  const response = await fetch(`${API_BASE_URL}/tasks/${taskId}`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  })

  if (!response.ok) {
    throw new Error(`Failed to get task status: ${response.statusText}`)
  }

  return response.json()
}

export async function exportContent(contentId: string, format: "jpg" | "png" | "mp4" | "gif"): Promise<ExportResponse> {
  const response = await fetch(`${API_BASE_URL}/export`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      content_id: contentId,
      format,
    }),
  })

  if (!response.ok) {
    throw new Error(`Failed to export content: ${response.statusText}`)
  }

  return response.json()
}

export async function schedulePost(
  content: string,
  scheduledTime: string,
  platforms: string[],
): Promise<ScheduleResponse> {
  const response = await fetch(`${API_BASE_URL}/schedule`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      content,
      scheduled_time: scheduledTime,
      platforms,
    }),
  })

  if (!response.ok) {
    throw new Error(`Failed to schedule post: ${response.statusText}`)
  }

  return response.json()
}

export async function pollTaskStatus(
  taskId: string,
  onProgress?: (status: TaskStatusResponse) => void,
): Promise<TaskStatusResponse> {
  return new Promise((resolve, reject) => {
    const poll = async () => {
      try {
        const status = await getTaskStatus(taskId)

        if (onProgress) {
          onProgress(status)
        }

        if (status.status === "completed") {
          resolve(status)
        } else if (status.status === "failed") {
          reject(new Error(status.error || "Task failed"))
        } else {
          setTimeout(poll, 2000)
        }
      } catch (error) {
        reject(error)
      }
    }

    poll()
  })
}
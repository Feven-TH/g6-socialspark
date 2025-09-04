# SocialSpark API Documentation

## Overview
SocialSpark is a comprehensive API for generating social media content including captions, images, videos, and managing content scheduling. The API provides AI-powered content generation with brand customization capabilities.

**Base URL:** `http://localhost:8000` (or your deployed URL)

---

## Authentication
Currently, no authentication is required for the API endpoints.

---

## Endpoints

### 1. Captions

#### Generate Caption
Generate AI-powered captions for social media posts with brand customization.

**Endpoint:** `POST /generate/caption`

**Request Body:**
```json
{
  "idea": "A new product launch for eco-friendly water bottles",
  "platform": "instagram",
  "language": "English",
  "hashtags_count": 4,
  "brand_presets": {
    "name": "EcoLife",
    "colors": ["#2E8B57", "#90EE90", "#FFFFFF"],
    "tone": "friendly and eco-conscious",
    "default_hashtags": ["#EcoLife", "#Sustainable"],
    "footer_text": "🌱 Making the world greener, one bottle at a time"
  }
}
```

**Request Parameters:**
- `idea` (string, required): The main concept or idea for the caption
- `platform` (string, optional): Target platform (default: "instagram")
- `language` (string, optional): Language for the caption (default: "English")
- `hashtags_count` (integer, optional): Number of hashtags to generate (default: 4)
- `brand_presets` (object, required): Brand configuration object

**Response Example:**
```json
{
  "caption": "🌊 Introducing our revolutionary eco-friendly water bottles! Made from 100% recycled materials, these bottles are perfect for your daily hydration needs while caring for our planet. Join the sustainable movement today! 🌱 Making the world greener, one bottle at a time",
  "hashtags": ["#EcoFriendly", "#SustainableLiving", "#ZeroWaste", "#GreenLife"]
}
```

**Error Response:**
```json
{
  "detail": "Failed to generate captions: [error message]"
}
```

---

### 2. Images

#### Generate Image Prompt
Generate enhanced prompts for image generation based on user input and brand guidelines.

**Endpoint:** `POST /generate/image`

**Request Body:**
```json
{
  "prompt": "A modern eco-friendly water bottle on a wooden table",
  "style": "realistic",
  "aspect_ratio": "1:1",
  "brand_presets": {
    "name": "EcoLife",
    "colors": ["#2E8B57", "#90EE90", "#FFFFFF"],
    "tone": "friendly and eco-conscious",
    "default_hashtags": ["#EcoLife", "#Sustainable"],
    "footer_text": "🌱 Making the world greener, one bottle at a time"
  },
  "platform": "instagram"
}
```

**Request Parameters:**
- `prompt` (string, required): Base prompt for image generation
- `style` (string, optional): Image style (default: "realistic")
- `aspect_ratio` (string, optional): Image dimensions (default: "1:1")
- `brand_presets` (object, required): Brand configuration
- `platform` (string, required): Target platform

**Response Example:**
```json
{
  "prompt_used": "A modern eco-friendly water bottle on a wooden table, featuring green and white colors, minimalist design, natural lighting, professional product photography, sustainable materials visible, clean background",
  "style": "realistic",
  "aspect_ratio": "1:1",
  "platform": "instagram"
}
```

#### Render Image
Submit an image for rendering using the generated prompt.

**Endpoint:** `POST /render/image`

**Request Body:**
```json
{
  "prompt_used": "A modern eco-friendly water bottle on a wooden table, featuring green and white colors, minimalist design, natural lighting, professional product photography, sustainable materials visible, clean background",
  "style": "realistic",
  "aspect_ratio": "1:1",
  "platform": "instagram"
}
```

**Response Example:**
```json
{
  "task_id": "img_12345678-1234-1234-1234-123456789abc",
  "status": "pending",
  "message": "Image rendering task created successfully"
}
```

#### Get Image Status
Check the status of an image rendering task.

**Endpoint:** `GET /status/{task_id}`

**Path Parameters:**
- `task_id` (string, required): The task ID returned from the render image endpoint

**Response Example (Pending):**
```json
{
  "task_id": "img_12345678-1234-1234-1234-123456789abc",
  "status": "pending",
  "progress": 25,
  "message": "Image is being processed"
}
```

**Response Example (Completed):**
```json
{
  "task_id": "img_12345678-1234-1234-1234-123456789abc",
  "status": "completed",
  "progress": 100,
  "result": {
    "image_url": "https://example.com/generated-image.jpg",
    "thumbnail_url": "https://example.com/thumbnail.jpg"
  }
}
```

**Response Example (Failed):**
```json
{
  "task_id": "img_12345678-1234-1234-1234-123456789abc",
  "status": "failed",
  "error": "Image generation failed due to invalid prompt"
}
```

---

### 3. Videos

#### Generate Storyboard
Create a storyboard for video content with multiple shots and music recommendations.

**Endpoint:** `POST /generate/storyboard`

**Request Body:**
```json
{
  "idea": "Showcase the benefits of our eco-friendly water bottle",
  "language": "English",
  "number_of_shots": 5,
  "platform": "instagram",
  "brand_presets": {
    "name": "EcoLife",
    "colors": ["#2E8B57", "#90EE90", "#FFFFFF"],
    "tone": "friendly and eco-conscious",
    "default_hashtags": ["#EcoLife", "#Sustainable"],
    "footer_text": "🌱 Making the world greener, one bottle at a time"
  },
  "cta": "Shop now at ecolife.com"
}
```

**Request Parameters:**
- `idea` (string, required): Main concept for the video
- `language` (string, optional): Language for the storyboard
- `number_of_shots` (integer, optional): Number of shots in the video
- `platform` (string, required): Target platform
- `brand_presets` (object, required): Brand configuration
- `cta` (string, required): Call-to-action text

**Response Example:**
```json
{
  "shots": [
    {
      "duration": 3,
      "text": "Close-up of hands holding the eco-friendly water bottle"
    },
    {
      "duration": 4,
      "text": "Bottle being filled with crystal clear water"
    },
    {
      "duration": 3,
      "text": "Person drinking from the bottle in nature"
    },
    {
      "duration": 4,
      "text": "Recycling symbol and eco-friendly materials showcase"
    },
    {
      "duration": 3,
      "text": "Brand logo with call-to-action text overlay"
    }
  ],
  "music": "upbeat"
}
```

#### Render Video
Submit a storyboard for video rendering.

**Endpoint:** `POST /render/video`

**Request Body:**
```json
{
  "shots": [
    {
      "duration": 3,
      "text": "Close-up of hands holding the eco-friendly water bottle"
    },
    {
      "duration": 4,
      "text": "Bottle being filled with crystal clear water"
    }
  ],
  "music": "upbeat"
}
```

**Response Example:**
```json
{
  "task_id": "vid_12345678-1234-1234-1234-123456789abc",
  "status": "pending",
}
```

---

### 4. Schedule

#### Create Schedule
Schedule content for posting on social media platforms.

**Endpoint:** `POST /schedule`

**Request Body:**
```json
{
  "asset_id": "img_12345678-1234-1234-1234-123456789abc",
  "platforms": ["instagram", "facebook"],
  "run_at": "2024-01-15T09:00:00Z",
  "post_text": "Check out our new eco-friendly water bottle! 🌱 #EcoLife #Sustainable"
}
```

**Request Parameters:**
- `asset_id` (string, required): ID of the generated content asset
- `platforms` (array, required): List of platforms to post on
- `run_at` (datetime, optional): Scheduled posting time (ISO format)
- `post_text` (string, optional): Text to accompany the post

**Response Example:**
```json
{
  "status": "scheduled",
  "scheduled_at": "2024-01-15T09:00:00Z",
  "postID": "post_12345678-1234-1234-1234-123456789abc"
}
```

#### Schedule Reminder
Set up a reminder for content posting.

**Endpoint:** `POST /schedule/reminder`

**Request Body:**
```json
{
  "asset_id": "img_12345678-1234-1234-1234-123456789abc",
  "platform": "instagram",
  "run_at": "2024-01-15T08:45:00Z"
}
```

**Response Example:**
```json
{
  "status": "reminder_scheduled",
  "scheduled_for": "2024-01-15T08:45:00Z"
}
```

#### Get Schedule by Asset ID
Retrieve schedule information for a specific asset.

**Endpoint:** `GET /schedule/{asset_id}`

**Path Parameters:**
- `asset_id` (string, required): The asset ID to look up

**Response Example:**
```json
{
  "asset_id": "img_12345678-1234-1234-1234-123456789abc",
  "platform": "instagram",
  "run_at": "2024-01-15T09:00:00Z",
  "status": "scheduled"
}
```

**Error Response (Not Found):**
```json
{
  "detail": "Schedule not found"
}
```

---

### 5. Tasks

#### Get Task Status
Check the status of any background task (images, videos, etc.).

**Endpoint:** `GET /tasks/{task_id}`

**Path Parameters:**
- `task_id` (string, required): The task ID to check

**Response Example (In Progress):**
```json
{
  "task_id": "img_12345678-1234-1234-1234-123456789abc",
  "status": "in_progress",
  "progress": 65,
  "message": "Processing image generation",
  "created_at": "2024-01-15T08:00:00Z",
  "updated_at": "2024-01-15T08:05:00Z"
}
```

**Response Example (Completed):**
```json
{
  "task_id": "img_12345678-1234-1234-1234-123456789abc",
  "status": "completed",
  "progress": 100,
  "result": {
    "output_url": "https://example.com/generated-content.jpg",
    "metadata": {
      "file_size": "2.5MB",
      "dimensions": "1080x1080",
      "format": "JPEG"
    }
  },
  "created_at": "2024-01-15T08:00:00Z",
  "completed_at": "2024-01-15T08:10:00Z"
}
```

---

## Data Models

### Brand Object
```json
{
  "name": "string",
  "colors": ["string"],
  "tone": "string",
  "default_hashtags": ["string"] | null,
  "footer_text": "string" | null
}
```

### Shot Object (for videos)
```json
{
  "duration": "integer (3-5 seconds)",
  "text": "string (scene description)"
}
```

---

## Error Handling

All endpoints return standard HTTP status codes:

- `200` - Success
- `400` - Bad Request (invalid input)
- `404` - Not Found
- `500` - Internal Server Error

Error responses follow this format:
```json
{
  "detail": "Error description"
}
```

---

## Rate Limiting

Currently, no rate limiting is implemented. Consider implementing rate limiting for production use.

---

## Examples

### Complete Workflow Example

1. **Generate Caption:**
```bash
curl -X POST "http://localhost:8000/generate/caption" \
  -H "Content-Type: application/json" \
  -d '{
    "idea": "New product launch",
    "platform": "instagram",
    "brand_presets": {
      "name": "MyBrand",
      "colors": ["#FF0000", "#FFFFFF"],
      "tone": "professional"
    }
  }'
```

2. **Generate Image:**
```bash
curl -X POST "http://localhost:8000/generate/image" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Product showcase",
    "platform": "instagram",
    "brand_presets": {
      "name": "MyBrand",
      "colors": ["#FF0000", "#FFFFFF"],
      "tone": "professional"
    }
  }'
```

3. **Render Image:**
```bash
curl -X POST "http://localhost:8000/render/image" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt_used": "Enhanced product showcase prompt",
    "style": "realistic",
    "aspect_ratio": "1:1",
    "platform": "instagram"
  }'
```

4. **Check Status:**
```bash
curl -X GET "http://localhost:8000/status/img_12345678-1234-1234-1234-123456789abc"
```

5. **Schedule Post:**
```bash
curl -X POST "http://localhost:8000/schedule" \
  -H "Content-Type: application/json" \
  -d '{
    "asset_id": "img_12345678-1234-1234-1234-123456789abc",
    "platforms": ["instagram"],
    "run_at": "2024-01-15T09:00:00Z",
    "post_text": "Check out our new product!"
  }'
```

---

## Notes

- All datetime fields should be in ISO 8601 format (UTC)
- Task IDs are typically UUIDs with prefixes indicating the content type
- Brand presets are required for most content generation endpoints
- The API supports CORS for cross-origin requests
- File uploads and downloads are handled through URLs in the response objects
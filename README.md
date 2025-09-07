# SocialSpark V1

AI-Powered Content Toolkit for Ethiopian SMEs & Creators

Mobile-First (Flutter) + Web (Next.js) • Thin GenAI Wrapper • Ethiopia-Focused

---

## Table of Contents

1. [Overview](#overview)
2. [Problem Statement](#problem-statement)
3. [Solution](#solution)
4. [Features](#features)
5. [Tech Stack](#tech-stack)
6. [Installation & Setup](#installation--setup)
7. [Usage](#usage)
8. [API Endpoints](#api-endpoints)
9. [Offline Strategy](#offline-strategy)
10. [License](#license)
11. [Contact](#contact)

---

## Overview

SocialSpark V1 is a lightweight AI assistant that transforms simple ideas into ready-to-publish Instagram and TikTok content. It generates captions, hashtags, and media assets (images or short videos), supports bilingual content (Amharic/English), and respects platform policies.

Designed for Ethiopian SMEs and content creators, SocialSpark helps produce content quickly, locally relevant, and cost-effectively.

Status:
- Web interface (Next.js under `web/`) is fully implemented in V1.
- Mobile Flutter app (under `mobile/socialspark_app`) is also working in V1.

---

## Problem Statement

SMEs and creators face challenges creating consistent, high-quality content:

- Limited time and skills
- High costs for agencies
- Complex existing tools
- Slow/spotty internet connectivity
- Publishing in Amharic with local context is particularly challenging

Goal: Provide a simple, offline-friendly assistant that converts ideas into polished social media posts.

---

## Solution

SocialSpark V1 allows users to:

1. Input a natural-language idea (EN/Amharic).
2. Generate captions, hashtags, and either:
   - A single image, or
   - A 15–30s short video (clips with text overlays).
3. Apply brand style presets: tone, colors, emoji usage, and hashtags.
4. Publish directly via Ayrshare (Instagram & Pinterest) or export + share.

All content is platform-safe, copyright-safe, and supports offline-first workflows.

---

## Features

- Natural Language Idea Box: Input ideas → caption, hashtags, media plan.
- One-Tap Variations: Change tone, shorten, or toggle Amharic/English.
- Brand Presets: Tone, colors, default hashtags, logo placement.
- Media Generation:
  - Image: single panel with optional overlay.
  - Video: 3–5 shot storyboard → async MP4 with text + music.
- Caption Helper: Auto CTA, ETB formatting, bilingual toggle.
- Export & Posting:
  - Direct publishing via Ayrshare (Instagram & Pinterest)
  - Fallback: export + share sheet
- Offline Drafts: Cache drafts/assets locally; resume uploads when online.

Web Interface (Completed in V1): Next.js-based minimal composer and asset library.

Mobile App (Working in V1): Flutter-based composer, editing, and asset handling.

---

## Tech Stack

Mobile Application:

- Framework: Flutter
- Local Storage: sqflite for caching drafts and assets
- UI: Custom widgets for content creation, editing, and scheduling

Backend Services:

- API Framework: FastAPI (Python)
- AI Services:
  - Caption & Hashtag Generation
  - Image Generation (DALL·E-style)
  - Video Rendering (short clips with text overlays and royalty-free music)
- Social Media Posting:
  - Ayrshare integration for Instagram and Pinterest posting
  - Share fallbacks when API restrictions apply
- Storage: S3-compatible object storage for media assets
- Authentication: OAuth via Ayrshare for Instagram/Pinterest

Web Interface (Completed):

- Framework: Next.js (TypeScript)
- Functionality: Minimal composer and asset library for demonstration

---

## Installation & Setup

### Prerequisites

- Flutter SDK (for mobile)
- Node.js 18+ and npm (for web)
- Backend prerequisites (from backend README):
  - Docker and Docker Compose
  - Python 3.12.3 or later (for manual setup)
  - API keys: Pixabay, Gemini, Freesound, Ayrshare

### Mobile Application (Working in V1)

```bash
git clone https://github.com/A2SV/g6-socialspark.git
cd g6-socialspark/mobile/socialspark_app
flutter pub get
flutter run
```

### Backend Services (from backend README)

Prerequisites:
- Docker and Docker Compose (recommended) OR Python 3.12+ for manual setup
- API keys for: Pixabay, Gemini, Freesound, and Ayrshare (create `.env` based on `.env.example`)

Getting Started (Docker - Recommended):

```bash
git clone https://github.com/A2SV/g6-socialspark
cd g6-socialspark/backend
cp .env.example .env
# Update the following in .env to use Docker service names instead of localhost:
# CELERY_BROKER_URI=redis://redis:6379/0
# CELERY_BACKEND_URI=redis://redis:6379/0
# MINIO_ENDPOINT=http://minio:9000

sudo docker compose build # only first time
sudo docker compose up
```

- App: http://localhost:8000
- MinIO Console: http://localhost:9001 (create a bucket named `videos` after starting)

Manual Setup:

```bash
git clone https://github.com/A2SV/g6-socialspark
cd g6-socialspark/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env

# Run dependencies in separate terminals
sudo docker run -dp 9000:9000 -p 9001:9001 -e "MINIO_ROOT_USER=admin" -e "MINIO_ROOT_PASSWORD=admin123" quay.io/minio/minio server /data --console-address ":9001"
sudo docker run -d --name redis -p 6379:6379 redis:latest

# Terminals
# 1) FastAPI Dev Server
fastapi dev delivery/main.py
# 2) Celery Worker
celery -A infrastructure.celery_app worker --loglevel=info
# 3) Celery Beat (Scheduler)
celery -A infrastructure.celery_app beat --loglevel=info
```

### Web Interface (Completed)

```bash
cd g6-socialspark/web
npm install
npm run dev
```

---

## Usage

1. Open SocialSpark (Mobile or Web) → Composer Screen.
2. Enter your idea (EN/Amharic).
3. Select media type: image or video.
4. Choose brand preset (tone/colors/logo).
5. Generate draft → variations available.
6. Edit overlays/caption if needed.
7. Publish via Ayrshare or export + share.

---

## API Endpoints (Sketch)

- POST /generate/caption → { caption, hashtags[] }
- POST /generate/image → { image_url }
- POST /generate/storyboard → { shots[] }
- POST /render/video → { task_id }
- GET /tasks/:id → { status, video_url }
- POST /export → packaged asset (PNG/MP4 + caption)
- POST /schedule → API schedule

Note: The backend entry point is `delivery/main.py` when using `fastapi dev`.

---

## Offline Strategy

- Mobile: Drafts & assets cached locally (sqflite). Video renders resume when online.
- Web: Local storage (e.g., localStorage/IndexedDB) used to cache drafts and assets.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Contact

For inquiries or contributions, please use the repository Issues section.

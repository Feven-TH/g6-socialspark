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
7. [Usage](#Usage)
8. [Contributing](#Contributing)
9. [License](#license)
10. [Contact](#contact)

---

## Overview

SocialSpark V1 is a lightweight AI assistant that transforms simple ideas into ready-to-publish Instagram and TikTok content. It generates captions, hashtags, and media assets (images or short videos), supports bilingual content (Amharic/English), and respects platform policies.

Designed for Ethiopian SMEs and content creators, SocialSpark helps produce content quickly, locally relevant, and cost-effectively.

---

## Problem Statement

SMEs and creators face challenges creating consistent, high-quality content:

- Limited time and skills
- High costs for agencies
- Complex existing tools
- Publishing in Amharic with local context is particularly challenging

Goal: Provide a simple assistant that converts ideas into polished social media posts.

---

## Solution

SocialSpark V1 allows users to:

1. Input a natural-language idea (EN/Amharic).
2. Generate captions, hashtags, and either:
   - A single image, or
   - A 15–30s short video (clips with text overlays).
3. Apply brand style presets: tone, colors, emoji usage, and hashtags.
4. Publish directly via AryShare (Instagram & Pinterest) or export.

---

## Features

### Core Features (V1)

- Natural Language Idea Box: Input ideas → caption, hashtags, media plan.
- One-Tap Variations: Change tone, shorten, or toggle Amharic/English.
- Brand Presets: Tone, colors, default hashtags.
- Media Generation:
  - Image: single panel with optional overlay.
  - Video: 3–5 shot storyboard → async MP4 with text + music.
- Caption Helper: Auto CTA, ETB formatting, bilingual toggle.
- Export & Posting:
  - Direct publishing via AryShare (Instagram & Pinterest)
  - Fallback: export
- Offline Drafts: Cache drafts/assets locally; resume uploads when online.

---

## Tech Stack

## Mobile Application:

- Framework: Flutter
- Local Storage: sqflite for caching drafts and assets
- UI: Custom widgets for content creation, editing, and scheduling

## Backend Services:

- API Framework: FastAPI (Python)
- AI Services:
  - Caption & Hashtag Generation
  - Image Generation (DALL·E-style)
  - Video Rendering (short clips with text overlays and royalty-free music)
- Social Media Posting:
  - AryShare integration for Instagram and Pinterest posting
- Storage: S3-compatible object storage for media assets
- Authentication: OAuth via AryShare for Instagram/Pinterest

## Web Interface

- **Framework**: [Next.js 14+](https://nextjs.org/) (App Router, TypeScript)
- **Language**: TypeScript
- **Styling**: [Tailwind CSS](https://tailwindcss.com/) for utility-first design
- **UI Components**: [shadcn/ui](https://ui.shadcn.com/) (Radix + Tailwind components) + custom reusable components
- **State Management**: [Redux Toolkit](https://redux-toolkit.js.org/) with RTK Query for API calls

---

## Installation & Setup

### Prerequisites

- Flutter SDK (for mobile)
- Python 3.10+ (for backend)
- Node.js 18+ and npm (for web)

### Mobile Application

```bash
git clone https://github.com/A2SV/g6-socialspark.git
cd g6-socialspark/mobile/socialspark_app
flutter pub get
flutter run
```

### Backend Services

```bash
cd g6-socialspark/backend
python -m venv venv

# Activate virtual environment
# Windows
./venv/Scripts/activate
# macOS/Linux
source venv/bin/activate

pip install -r requirements.txt

# Run FastAPI (module path matches repo structure)
uvicorn delivery.main:app --reload
```

Optional: using Docker Compose (dev)

```bash
cd g6-socialspark/backend
docker compose up --build
```

If environment variables are required, copy `.env.example` to `.env` and configure as needed.

### Web Interface

```bash
cd g6-socialspark/web
npm install
npm run dev
```

This launches the Next.js app on the default development port.

---

## Usage

1. Open SocialSpark (Mobile or Web) → Composer Screen.
2. Enter your idea (EN/Amharic).
3. Select media type: image or video.
4. Choose brand preset (tone/colors/logo).
5. Generate draft → variations available.
6. Edit overlays/caption if needed.
7. Publish via AryShare or export.

---

## Contributing

PRs and issues are welcome. Please open an issue first to discuss major changes.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Contact

For inquiries or contributions, please use the repository Issues section.

from infrastructure.celery_app import celery_app
from infrastructure.storage_service import upload_file, get_download_url
from infrastructure.stable_horde_service import StableHordeService
from dotenv import load_dotenv
import os
import requests
import tempfile
import uuid
import ffmpeg
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
import ffmpeg
import os
import logging
import requests
import datetime
import io
import tempfile
import uuid
from typing import Optional, Dict
from PIL import Image, UnidentifiedImageError
from infrastructure.celery_app import celery_app
from infrastructure.storage_service import upload_file, get_download_url
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("tasks")
logger.setLevel(logging.INFO)
if not logger.hasHandlers():
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    ch.setFormatter(formatter)
    logger.addHandler(ch)

MAX_INSTAGRAM_WIDTH = 6000
MAX_INSTAGRAM_HEIGHT = 6000


@celery_app.task(bind=True, autoretry_for=(Exception,), retry_kwargs={"max_retries": 3})
def publish_post(self, post_data: Dict):
    API_KEY = os.getenv("AYRSHARE_API_KEY")
    logger.info(f"Loaded AYRSHARE_API_KEY: {API_KEY}")
    if not API_KEY:
        logger.error("Ayrshare API key not found in environment variables.")
        return

    asset_id = post_data["asset_id"]
    platforms = post_data["platforms"]
    supported_platforms = {
        "instagram",
        "facebook",
        "pinterest",
        "twitter",
        "linkedin",
        "googlebusinessprofile",
    }

    for p in platforms:
        if p not in supported_platforms:
            logger.error(f"Platform not supported: {p}")
            raise ValueError(f"Platform '{p}' not supported.")

    post_text = post_data.get("post_text", "")
    run_at: Optional[datetime.datetime] = post_data.get("run_at")

    if asset_id.startswith("http://") or asset_id.startswith("https://"):
        media_url = asset_id
    else:
        media_url = f"https://your-s3-bucket.s3.amazonaws.com/{asset_id}.jpg"

    logger.info(f"Media URL: {media_url}")

    # --- Image Resizing Logic ---
    try:
        image_response = requests.get(media_url)
        image_response.raise_for_status()

        image_buffer = io.BytesIO(image_response.content)
        img = Image.open(image_buffer)

        width, height = img.size
        logger.info(f"Original image dimensions: {width}x{height}")

        payload = {
            "post": post_text,
            "platforms": platforms,
        }

        if run_at:
            payload["scheduleDate"] = run_at.isoformat()

        logger.info(f"Attempting to post to Ayrshare API for platforms: {platforms}")

        if width > MAX_INSTAGRAM_WIDTH or height > MAX_INSTAGRAM_HEIGHT:
            logger.info("Image exceeds size limits. Resizing...")

            ratio = min(MAX_INSTAGRAM_WIDTH / width, MAX_INSTAGRAM_HEIGHT / height)
            new_width = int(width * ratio)
            new_height = int(height * ratio)

            resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

            resized_image_buffer = io.BytesIO()
            resized_img.save(resized_image_buffer, format=img.format)
            resized_image_buffer.seek(0)

            files = {
                "media": (
                    f"resized_{asset_id}.jpg",
                    resized_image_buffer,
                    f"image/{img.format.lower()}",
                )
            }
            response = requests.post(
                "https://api.ayrshare.com/api/post",
                headers={"Authorization": f"Bearer {API_KEY}"},
                data=payload,
                files=files,
            )
        else:
            payload["mediaUrls"] = [media_url]
            response = requests.post(
                "https://api.ayrshare.com/api/post",
                headers={
                    "Authorization": f"Bearer {API_KEY}",
                    "Content-Type": "application/json",
                },
                json=payload,
            )

    except requests.exceptions.RequestException as e:
        logger.error(f"Error downloading or posting image: {e}")
        raise self.retry(exc=e)

    except UnidentifiedImageError as e:
        logger.error(f"The asset '{asset_id}' is not a valid image file: {e}")
        return

    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")
        raise self.retry(exc=e)

    logger.info(f"Ayrshare response status: {response.status_code}")
    logger.info(f"Ayrshare response body: {response.text}")
    response.raise_for_status()
    logger.info(f"Post to {platforms} successful: {response.json()}")


def prepare_music(music_desc: str):
    url = os.getenv("FREESOUND_SEARCH_URL")
    response = requests.get(
        url,
        params={
            "query": music_desc,
            "token": os.getenv("FREESOUND_API_KEY"),
            "fields": "previews",
        },
    )
    results = response.json()["results"]
    if len(results) > 0:
        music_url = response.json()["results"][0]["previews"]["preview-lq-mp3"]
        return music_url
    return None


def stitch_clips(
    clip_urls: list[str], durations: list[int], output_file: str, music_url: str = None
):
    """
    Stitches individual clips and adds background music
    """
    # Create normalized streams
    inputs = []
    for i, url in enumerate(clip_urls):
        stream = ffmpeg.input(url, ss=0, t=durations[i])
        stream = stream.filter("scale", 1280, 720)
        inputs.append(stream)

    # Concatenate all video streams
    video_stream = ffmpeg.concat(*inputs, v=1, a=0).node[0]

    if music_url:
        audio_stream = ffmpeg.input(music_url)
        # Use amix to loop audio to match video duration
        mixed_audio = ffmpeg.filter(
            [audio_stream], "amix", inputs=1, duration="first", dropout_transition=0
        )
        out = ffmpeg.output(
            video_stream,
            mixed_audio,
            output_file,
            vcodec="libx264",
            acodec="aac",
            shortest=None,
        )
    else:
        out = ffmpeg.output(video_stream, output_file, vcodec="libx264", acodec="aac")

    # Run the ffmpeg pipeline
    ffmpeg.run(out, overwrite_output=True)


def serve_video(clips: list[str], durations: list[int], music_desc: str):
    """
    Store and generate download link for the generated videos
    """
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp_video:
        output_path = tmp_video.name

    try:
        music_url = prepare_music(music_desc)
        stitch_clips(clips, durations, output_path, music_url)

        with open(output_path, "rb") as f:
            object_name = f"video_{uuid.uuid4()}.mp4"
            upload_file(f, object_name, "videos")

        download_url = get_download_url(object_name, "videos")
        return download_url

    finally:
        if os.path.exists(output_path):
            os.remove(output_path)


@celery_app.task(bind=True)
def render_video(self, payload):
    url = os.getenv("PIXABAY_VIDEO_URL")
    clips = []
    durations = []

    for shot in payload["shots"]:
        response = requests.get(
            url, params={"key": os.getenv("PIXABAY_API_KEY"), "q": shot["text"]}
        )
        hits = response.json()["hits"]
        if len(hits) > 0:
            video_url = response.json()["hits"][0]["videos"]["tiny"]["url"]
            clips.append(video_url)
            durations.append(shot["duration"])
    return serve_video(clips, durations, payload["music"])


@celery_app.task(bind=True, time_limit=900, soft_time_limit=800)  # 15 min timeout
def render_image(self, image_data):
    """
    Celery task to render an image using Stable Horde API.
    """
    try:
        logger.info(f"Starting render_image task with data: {image_data}")

        # Update task status
        self.update_state(
            state="PROCESSING",
            meta={"progress": 10, "message": "Starting image generation"},
        )

        prompt = image_data["prompt_used"]
        style = image_data["style"]
        aspect_ratio = image_data["aspect_ratio"]
        platform = image_data["platform"]

        logger.info(
            f"Extracted parameters - Prompt: {prompt[:50]}..., Style: {style}, Aspect: {aspect_ratio}"
        )

        # Initialize Stable Horde service
        logger.info("Initializing Stable Horde service")
        stable_horde = StableHordeService()

        # Update progress
        self.update_state(
            state="PROCESSING",
            meta={"progress": 20, "message": "Submitting to Stable Horde"},
        )

        # Generate image using Stable Horde
        logger.info("Calling Stable Horde generate_image")
        result = stable_horde.generate_image(
            prompt=prompt, style=style, aspect_ratio=aspect_ratio
        )

        logger.info(f"Stable Horde returned result: {result}")

        # Update progress
        self.update_state(
            state="PROCESSING", meta={"progress": 90, "message": "Processing complete"}
        )

        final_result = {
            "status": "completed",
            "image_url": result["image_url"],
            "prompt_used": prompt,
            "style": style,
            "aspect_ratio": aspect_ratio,
            "platform": platform,
            "metadata": {
                "seed": result.get("seed"),
                "worker_id": result.get("worker_id"),
                "worker_name": result.get("worker_name"),
                "model": result.get("model"),
            },
        }

        logger.info(f"Task completed successfully: {final_result}")
        return final_result

    except Exception as e:
        logger.error(f"Error in render_image task: {str(e)}", exc_info=True)
        self.update_state(
            state="FAILURE",
            meta={"error": str(e), "message": f"Image generation failed: {str(e)}"},
        )
        raise


@celery_app.task(name="usecases.tasks.send_reminder")
def send_reminder(asset_id: str, platform: str):
    from repository import schedule_repository
    from datetime import datetime

    print(
        f"[REMINDER] {datetime.utcnow().isoformat()} UTC - Asset {asset_id} scheduled for {platform}"
    )

    schedule_repository.update_status(asset_id, "done")

    return {"asset_id": asset_id, "platform": platform, "status": "done"}

from infrastructure.celery_app import celery_app
import os
import logging
import requests
from typing import Optional, Dict
import datetime
from PIL import Image, UnidentifiedImageError 
import io

logger = logging.getLogger("publish_post")
logger.setLevel(logging.INFO)
if not logger.hasHandlers():
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
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
    supported_platforms = {"instagram", "facebook", "pinterest", "twitter", "linkedin", "googlebusinessprofile"}

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

        if width > MAX_INSTAGRAM_WIDTH or height > MAX_INSTAGRAM_HEIGHT:
            logger.info("Image exceeds size limits. Resizing...")

            ratio = min(MAX_INSTAGRAM_WIDTH / width, MAX_INSTAGRAM_HEIGHT / height)
            new_width = int(width * ratio)
            new_height = int(height * ratio)

            resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

            resized_image_buffer = io.BytesIO()
            resized_img.save(resized_image_buffer, format=img.format)
            resized_image_buffer.seek(0)

            files = {'media': (f"resized_{asset_id}.jpg", resized_image_buffer, f"image/{img.format.lower()}")}
            response = requests.post("https://api.ayrshare.com/api/post", headers={"Authorization": f"Bearer {API_KEY}"}, data=payload, files=files)
        else:
            payload["mediaUrls"] = [media_url]
            response = requests.post("https://api.ayrshare.com/api/post", headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}, json=payload)

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
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

load_dotenv()


def stitch_clips(clip_urls: list[str], durations: list[int], output_file: str):
    """
    Stitches individual clips and adds background music
    """
    # Create normalized streams
    inputs = []
    for i, url in enumerate(clip_urls):
        stream = ffmpeg.input(url, ss=0, t=durations[i])
        stream = stream.filter("scale", 1280, 720)  # normalize resolution
        inputs.append(stream)

    # Concatenate all video streams
    joined = ffmpeg.concat(*inputs, v=1, a=0).node
    video = joined[0]

    # Define final output
    out = ffmpeg.output(video, output_file, vcodec="libx264", acodec="aac")

    # Run the ffmpeg pipeline
    ffmpeg.run(out, overwrite_output=True)


def serve_video(clips: list[str], durations: list[int]):
    """
    Store and generate download link for the generated videos
    """
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp_video:
        output_path = tmp_video.name

    try:
        stitch_clips(clips, durations, output_path)

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
        video_url = response.json()["hits"][0]["videos"]["tiny"]["url"]
        clips.append(video_url)
        durations.append(shot["duration"])
    return serve_video(clips, durations)


@celery_app.task(bind=True, time_limit=900, soft_time_limit=800)  # 15 min timeout
def render_image(self, image_data):
    """
    Celery task to render an image using Stable Horde API.
    """
    try:
        logger.info(f"Starting render_image task with data: {image_data}")
        
        # Update task status
        self.update_state(state='PROCESSING', meta={'progress': 10, 'message': 'Starting image generation'})
        
        prompt = image_data['prompt_used']
        style = image_data['style']
        aspect_ratio = image_data['aspect_ratio']
        platform = image_data['platform']
        
        logger.info(f"Extracted parameters - Prompt: {prompt[:50]}..., Style: {style}, Aspect: {aspect_ratio}")
        
        # Initialize Stable Horde service
        logger.info("Initializing Stable Horde service")
        stable_horde = StableHordeService()
        
        # Update progress
        self.update_state(state='PROCESSING', meta={'progress': 20, 'message': 'Submitting to Stable Horde'})
        
        # Generate image using Stable Horde
        logger.info("Calling Stable Horde generate_image")
        result = stable_horde.generate_image(
            prompt=prompt,
            style=style,
            aspect_ratio=aspect_ratio
        )
        
        logger.info(f"Stable Horde returned result: {result}")
        
        # Update progress
        self.update_state(state='PROCESSING', meta={'progress': 90, 'message': 'Processing complete'})
        
        final_result = {
            'status': 'completed',
            'image_url': result['image_url'],
            'prompt_used': prompt,
            'style': style,
            'aspect_ratio': aspect_ratio,
            'platform': platform,
            'metadata': {
                'seed': result.get('seed'),
                'worker_id': result.get('worker_id'),
                'worker_name': result.get('worker_name'),
                'model': result.get('model')
            }
        }
        
        logger.info(f"Task completed successfully: {final_result}")
        return final_result
        
    except Exception as e:
        logger.error(f"Error in render_image task: {str(e)}", exc_info=True)
        self.update_state(
            state='FAILURE',
            meta={'error': str(e), 'message': f'Image generation failed: {str(e)}'}
        )
        raise

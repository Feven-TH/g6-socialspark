import ffmpeg
from infrastructure.celery_app import celery_app
from infrastructure.storage_service import upload_file, get_download_url
from dotenv import load_dotenv
import requests
import os
import tempfile
import uuid

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

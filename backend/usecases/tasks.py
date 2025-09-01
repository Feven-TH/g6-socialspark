import ffmpeg
from infrastructure.celery_app import celery_app
from infrastructure.storage_service import upload_file, get_download_url
from dotenv import load_dotenv
import requests
import os
import tempfile
import uuid

load_dotenv()


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
    print(response.json()["results"][0])
    music_url = response.json()["results"][0]["previews"]["preview-lq-mp3"]
    return music_url


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
        video_url = response.json()["hits"][0]["videos"]["tiny"]["url"]
        clips.append(video_url)
        durations.append(shot["duration"])
    return serve_video(clips, durations, payload["music"])

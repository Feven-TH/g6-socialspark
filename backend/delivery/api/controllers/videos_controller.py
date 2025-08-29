from domain.videos_dto import StoryboardRequest, RenderRequest
from usecases.videos_service import generate_storyboard, render_video
from fastapi import HTTPException

def generate_storyboard_controller(request: StoryboardRequest):
    try:
        return generate_storyboard(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate storyboard: {e}")

def render_video_controller(request: RenderRequest):
    try:
        return render_video(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to render video: {e}")

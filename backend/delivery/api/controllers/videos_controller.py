from domain.videos_dto import StoryboardRequest
from usecases.videos_service import generate_storyboard
from fastapi import HTTPException

def generate_storyboard_controller(request: StoryboardRequest):
    try:
        return generate_storyboard(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate storyboard: {e}")

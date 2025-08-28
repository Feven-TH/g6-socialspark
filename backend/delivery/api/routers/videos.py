from fastapi import APIRouter, HTTPException
from domain.videos_dto import StoryboardRequest
from delivery.api.controllers import videos_controller

router = APIRouter()

@router.post("/generate/storyboard")
def generate_storyboard(request: StoryboardRequest):
    try:
        return videos_controller.generate_storyboard_controller(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

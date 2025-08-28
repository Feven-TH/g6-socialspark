from fastapi import APIRouter
from domain.videos_dto import StoryboardRequest
from delivery.api.controllers import videos_controller

router = APIRouter()

@router.post("/generate/storyboard")
def generate_storyboard(request: StoryboardRequest):
    return videos_controller.generate_storyboard(request)

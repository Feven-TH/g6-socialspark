from domain.videos_dto import StoryboardRequest
from usecases.videos_service import generate_storyboard

def generate_storyboard_controller(request: StoryboardRequest):
    return generate_storyboard(request)

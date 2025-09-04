from domain.images_dto import ImageGenerationRequest, RenderImageRequest
from usecases.images_service import generate_image_prompt, create_render_image_task
from usecases.tasks_service import get_task_status
from fastapi import HTTPException


def generate_image_prompt_controller(request: ImageGenerationRequest):
    try:
        return generate_image_prompt(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate image prompt: {e}")


def render_image_controller(request: RenderImageRequest):
    try:
        return create_render_image_task(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to render image: {e}")


def get_image_status_controller(task_id: str):
    try:
        return get_task_status(task_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get image status: {e}")
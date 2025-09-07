from fastapi import APIRouter, HTTPException
from domain.images_dto import ImageGenerationRequest, RenderImageRequest
from delivery.api.controllers import images_controller

router = APIRouter()

@router.post("/generate/image")
def generate_image_prompt(request: ImageGenerationRequest):
    try:
        return images_controller.generate_image_prompt_controller(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/render/image")
def render_image(request: RenderImageRequest):
    try:
        return images_controller.render_image_controller(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/status/{task_id}")
def get_image_status(task_id: str):
    try:
        return images_controller.get_image_status_controller(task_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

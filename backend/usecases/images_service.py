from domain.images_dto import ImageGenerationRequest, ImageGenerationResponse, RenderImageRequest
from infrastructure.ai_services import get_structured_response
from templates.prompt_templates import IMAGE_GENERATION_PROMPT_TEMPLATE
from usecases.tasks import render_image


def generate_image_prompt(request: ImageGenerationRequest) -> ImageGenerationResponse:
    """
    Generates an image prompt and metadata based on the provided request.
    """
    try:
        # Enhance the prompt with brand information
        enhanced_prompt = f"{request.prompt}, {request.brand_presets.tone} style"
        if request.brand_presets.colors:
            enhanced_prompt += f", using colors: {', '.join(request.brand_presets.colors)}"
        
        input_variables = {
            "prompt": request.prompt,
            "enhanced_prompt": enhanced_prompt,
            "style": request.style or "realistic",
            "aspect_ratio": request.aspect_ratio or "1:1",
            "brand_name": request.brand_presets.name,
            "brand_tone": request.brand_presets.tone,
            "colors": ", ".join(request.brand_presets.colors) if request.brand_presets.colors else "default",
            "platform": request.platform,
        }

        return get_structured_response(
            prompt_template_str=IMAGE_GENERATION_PROMPT_TEMPLATE,
            input_variables=input_variables,
            pydantic_model=ImageGenerationResponse,
        )
    except Exception as e:
        raise Exception(f"Failed to generate image prompt: {e}")


def create_render_image_task(request: RenderImageRequest):
    """
    Creates an async task to render an image based on the provided request.
    """
    try:
        task = render_image.delay(request.model_dump())
        return {"task_id": task.id, "status": "queued"}
    except Exception as e:
        raise Exception(f"Failed to create render image task: {e}")
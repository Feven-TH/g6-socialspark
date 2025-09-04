from pydantic import BaseModel, Field
from domain.brand_dto import Brand


class ImageGenerationRequest(BaseModel):
    prompt: str
    style: str | None = Field(default="realistic", description="Image style (realistic, cartoon, artistic, etc.)")
    aspect_ratio: str | None = Field(default="1:1", description="Image aspect ratio (1:1, 16:9, 9:16, etc.)")
    brand_presets: Brand
    platform: str = Field(description="Target platform (instagram, facebook, twitter, etc.)")


class ImageGenerationResponse(BaseModel):
    prompt_used: str = Field(description="The enhanced prompt used for generation")
    style: str = Field(description="Style applied to the image")
    aspect_ratio: str = Field(description="Aspect ratio of the generated image")
    platform: str = Field(description="Target platform")


class RenderImageRequest(BaseModel):
    prompt_used: str
    style: str
    aspect_ratio: str
    platform: str
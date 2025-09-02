from pydantic import BaseModel, Field
from domain.brand_dto import Brand


class StoryboardRequest(BaseModel):
    idea: str
    language: str | None
    number_of_shots: int | None
    platform: str
    brand_presets: Brand
    cta: str


class Shot(BaseModel):
    duration: int = Field(
        description="The duration of the scene in seconds, between 3 - 5 (inclusive)"
    )
    text: str = Field(description="a short phrase describing a scene")


class StoryboardResponse(BaseModel):
    shots: list[Shot] = Field(description="A list of descriptions for video scenes")
    music: str = Field(
        description="One word description of the genre of the background music",
        examples=["upbeat", "downbeat", "jazz", "classical"],
    )


class RenderRequest(BaseModel):
    shots: list[Shot]
    music: str

from pydantic import BaseModel
from domain.brand_dto import Brand


class StoryboardRequest(BaseModel):
    idea: str
    language: str
    number_of_shots: int
    brand_presets: Brand

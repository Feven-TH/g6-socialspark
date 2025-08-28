from pydantic import BaseModel

class Brand(BaseModel):
    name: str
    tone: str
    colors: list[str]
    default_hashtags: list[str]
    footer_text: str

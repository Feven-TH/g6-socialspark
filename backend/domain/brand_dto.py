from pydantic import BaseModel

class Brand(BaseModel):
    name: str
    tone: str | None
    colors: list[str] | None
    default_hashtags: list[str] | None
    footer_text: str | None

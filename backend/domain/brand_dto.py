from pydantic import BaseModel, Field
from typing import List, Optional

class Brand(BaseModel):
    name: str
    colors: List[str]
    tone: str
    default_hashtags: Optional[List[str]] = Field(default=None, description="Default hashtags for the brand")
    footer_text: Optional[str] = Field(default=None, description="Footer text for the brand")

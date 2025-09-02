import datetime
from typing import List, Optional
from pydantic import BaseModel

class scheduleRequest(BaseModel):
    asset_id : str 
    platforms : List[str] 
    run_at: Optional[datetime.datetime] = None
    post_text: Optional[str]

class scheduledResponse(BaseModel):
    status : str
    scheduled_at : Optional[datetime.datetime] = None
    postID : str
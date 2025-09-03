from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime

class scheduleRequest(BaseModel):
    asset_id : str 
    platforms : List[str] 
    run_at: Optional[datetime] = None
    post_text: Optional[str]

class scheduledResponse(BaseModel):
    status : str
    scheduled_at : Optional[datetime] = None
    postID : str



class ScheduleReminderRequest(BaseModel):
	asset_id: str = Field(..., description="ID of the asset to post or remind about")
	platform: str = Field(..., description="Target platform, e.g., instagram")
	run_at: datetime = Field(..., description="UTC ISO datetime when the reminder should run")


class ScheduleReminderResponse(BaseModel):
	status: str
	scheduled_for: datetime


class ScheduleItem(BaseModel):
	asset_id: str
	platform: str
	run_at: datetime
	status: str

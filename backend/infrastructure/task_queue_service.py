import datetime
from typing import List, Optional
from usecases.tasks import publish_post

class TaskQueueService:
    def enqueue_post(self, asset_Id: str, platforms: List[str], post_text: Optional[str], run_at: Optional[datetime.datetime] = None):
        payload = {
            "asset_id": asset_Id,
            "platforms": platforms,
            "post_text": post_text,
        }

        if run_at:
            payload["run_at"] = run_at
            task = publish_post.apply_async(args=[payload], eta=run_at)
        else:
            task = publish_post.apply_async(args=[payload]) 
        return task.id

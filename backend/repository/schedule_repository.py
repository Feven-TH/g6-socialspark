import redis
import json
from typing import Optional
from datetime import datetime

r = redis.Redis(host="localhost", port=6379, db=0, decode_responses=True)

class ScheduledItem:
    def __init__(self, asset_id: str, platform: str, run_at: datetime, celery_task_id: str, status="queued"):
        self.asset_id = asset_id
        self.platform = platform
        self.run_at = run_at.isoformat() if isinstance(run_at, datetime) else run_at
        self.celery_task_id = celery_task_id
        self.status = status

    def to_dict(self):
        return {
            "asset_id": self.asset_id,
            "platform": self.platform,
            "run_at": self.run_at,
            "celery_task_id": self.celery_task_id,
            "status": self.status,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "ScheduledItem":
        run_at = datetime.fromisoformat(data["run_at"]) if isinstance(data["run_at"], str) else data["run_at"]
        return cls(
            asset_id=data["asset_id"],
            platform=data["platform"],
            run_at=run_at,
            celery_task_id=data["celery_task_id"],
            status=data.get("status", "queued"),
        )

def upsert(item: ScheduledItem):
    r.set(item.asset_id, json.dumps(item.to_dict()))

def get(asset_id: str) -> Optional[ScheduledItem]:
    data = r.get(asset_id)
    if data:
        return ScheduledItem.from_dict(json.loads(data))
    return None

def update_status(asset_id: str, new_status: str) -> bool:
    item = get(asset_id)
    if not item:
        return False
    item.status = new_status
    upsert(item)
    return True

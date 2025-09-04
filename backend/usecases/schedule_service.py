from datetime import datetime, timezone
from infrastructure.celery_app import celery_app
from domain.schedule_dto import (
	ScheduleReminderRequest,
	ScheduleReminderResponse,
	ScheduleItem,
    scheduleRequest,
)
from repository import schedule_repository


class SchedulePostUsecase:
    def __init__(self, taskQueue):
        self.taskQueue = taskQueue
    
    def create(self, request: scheduleRequest) -> dict:
        post_id = self.taskQueue.enqueue_post(
            asset_Id=request.asset_id,
            platforms=request.platforms,
            post_text=request.post_text,
            run_at=request.run_at
        )
        return {
            "status": "Queued",
            "scheduled_at": request.run_at,
            "postID": post_id
        }



def schedule_reminder_service(payload: ScheduleReminderRequest) -> ScheduleReminderResponse:
	run_at_utc = payload.run_at
	if run_at_utc.tzinfo is None:
		run_at_utc = run_at_utc.replace(tzinfo=timezone.utc)
	else:
		run_at_utc = run_at_utc.astimezone(timezone.utc)

	eta = run_at_utc
	async_result = celery_app.send_task(
		"usecases.tasks.send_reminder",
		kwargs={
			"asset_id": payload.asset_id,
			"platform": payload.platform,
		},
		eta=eta,
	)

	schedule_repository.upsert(
		schedule_repository.ScheduledItem(
			asset_id=payload.asset_id,
			platform=payload.platform,
			run_at=run_at_utc,
			celery_task_id=async_result.id,
		)
	)

	return ScheduleReminderResponse(status="queued", scheduled_for=run_at_utc)

def get_schedule_by_asset_id_service(asset_id: str) -> ScheduleItem | None:
    item = schedule_repository.get(asset_id)
    if not item:
        return None
    return ScheduleItem(
        asset_id=item.asset_id,
        platform=item.platform,
        run_at=item.run_at,
        status=item.status,
    )


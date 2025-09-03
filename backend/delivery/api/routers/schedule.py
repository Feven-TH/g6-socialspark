from fastapi import APIRouter, Depends, HTTPException
from domain.schedule_dto import (
	ScheduleReminderRequest,
	ScheduleReminderResponse,
	ScheduleItem,
	scheduleRequest,
	scheduledResponse,
    
)
from delivery.api.controllers import schedule_controller
from infrastructure.container import get_schedule_controller

router = APIRouter()

@router.post("/schedule", response_model=scheduledResponse)
def schedule_post(
    request: scheduleRequest,
    controller = Depends(get_schedule_controller)
):
    return controller.create_schedule(request)


@router.post("/schedule/reminder", response_model=ScheduleReminderResponse)
def schedule_reminder(payload: ScheduleReminderRequest):
	try:
		return schedule_controller.schedule_reminder_controller(payload)
	except Exception as e:
		raise HTTPException(status_code=500, detail=str(e))



@router.get("/schedule/{asset_id}", response_model=ScheduleItem)
def get_schedule(asset_id: str):
	item = schedule_controller.get_schedule_by_asset_id_controller(asset_id)
	if not item:
		raise HTTPException(status_code=404, detail="Schedule not found")
	return item


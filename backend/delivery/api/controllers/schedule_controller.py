from domain.schedule_dto import scheduleRequest, scheduledResponse
from domain.schedule_dto import ScheduleReminderRequest, ScheduleReminderResponse
from usecases.schedule_service import schedule_reminder_service
from usecases.schedule_service import (
	get_schedule_by_asset_id_service,
)
from domain.schedule_dto import ScheduleItem

class ScheduleController:
    def __init__(self, schedule_usecase):
        self.schedule_usecase = schedule_usecase

    def create_schedule(self, request: scheduleRequest) -> scheduledResponse:
        result = self.schedule_usecase.create(request)
        return scheduledResponse(**result)





def schedule_reminder_controller(payload: ScheduleReminderRequest) -> ScheduleReminderResponse:
	return schedule_reminder_service(payload)


def get_schedule_by_asset_id_controller(asset_id: str) -> ScheduleItem | None:
	return get_schedule_by_asset_id_service(asset_id)


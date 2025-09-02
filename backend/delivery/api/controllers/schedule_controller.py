from domain.schedule_dto import scheduleRequest, scheduledResponse

class ScheduleController:
    def __init__(self, schedule_usecase):
        self.schedule_usecase = schedule_usecase

    def create_schedule(self, request: scheduleRequest) -> scheduledResponse:
        result = self.schedule_usecase.create(request)
        return scheduledResponse(**result)

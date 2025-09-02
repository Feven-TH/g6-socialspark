from infrastructure.task_queue_service import TaskQueueService
from usecases.schedule_service import SchedulePostUsecase
from delivery.api.controllers.schedule_controller import ScheduleController

class AppContainer:
    def __init__(self):
        self.queueService = TaskQueueService()
        self.schedulePostUsecase = SchedulePostUsecase(self.queueService)
        self.schedule_controller = ScheduleController(self.schedulePostUsecase)

container = AppContainer()

def get_schedule_controller():
    return container.schedule_controller

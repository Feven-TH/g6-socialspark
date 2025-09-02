from fastapi import APIRouter, Depends
from domain.schedule_dto import scheduleRequest, scheduledResponse
from infrastructure.container import get_schedule_controller

router = APIRouter()

@router.post("/schedule", response_model=scheduledResponse)
def schedule_post(
    request: scheduleRequest,
    controller = Depends(get_schedule_controller)
):
    return controller.create_schedule(request)

from fastapi import APIRouter, HTTPException
from delivery.api.controllers import tasks_controller

router = APIRouter()


@router.get("/tasks/{task_id}")
def get_task_status(task_id: str):
    try:
        return tasks_controller.get_task_status_controller(task_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

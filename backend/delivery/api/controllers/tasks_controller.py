from usecases.tasks_service import get_task_status as get_task_status_usecase
from fastapi import HTTPException

def get_task_status_controller(task_id: str):
    try:
        return get_task_status_usecase(task_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get task status: {e}")

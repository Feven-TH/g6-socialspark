from celery.result import AsyncResult
from infrastructure.celery_app import celery_app


def get_task_status(task_id: str):
    """
    Returns the status of a Celery task.
    """
    try:
        task_result = AsyncResult(task_id, app=celery_app)

        status = task_result.status

        if status == "PENDING":
            response = {"status": "queued", "video_url": None}
        elif status == "SUCCESS":
            response = {"status": "ready", "video_url": task_result.get()}
        elif status == "FAILURE":
            response = {"status": "failed", "video_url": None}
        else:
            response = {"status": status}

        return response
    except Exception as e:
        raise Exception(f"Failed to get task status: {e}")

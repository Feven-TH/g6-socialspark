from domain.schedule_dto import scheduleRequest

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

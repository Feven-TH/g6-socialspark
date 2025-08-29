from infrastructure.celery_app import celery_app
import time


@celery_app.task(bind=True)
def render_video(self, payload):
    # dummy render simulation
    time.sleep(10)
    return "https://example.com/dummy_video.mp4"

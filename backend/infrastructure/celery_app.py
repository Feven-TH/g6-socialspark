import os
from dotenv import load_dotenv
from celery import Celery

load_dotenv()

celery_app = Celery(
    "socialspark",
    broker=os.getenv("CELERY_BROKER_URI"),
    backend=os.getenv("CELERY_BACKEND_URI"),
    include=["usecases.tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

if __name__ == "__main__":
    celery_app.start()

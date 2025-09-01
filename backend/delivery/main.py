from fastapi import FastAPI
from delivery.api.routers import captions, images, videos, schedule, tasks


def create_app():
    app = FastAPI(title="SocialSpark")

    # Register routers
    app.include_router(videos.router, prefix="", tags=["videos"])
    app.include_router(images.router, prefix="", tags=["images"])
    app.include_router(tasks.router, prefix="", tags=["tasks"])
    app.include_router(captions.router, prefix="", tags=["captions",])

    return app


app = create_app()

import os
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from delivery.api.routers import captions, images, videos, schedule, tasks

load_dotenv()


def create_app():
    app = FastAPI(title="SocialSpark")

    # CORS Middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Register routers
    app.include_router(videos.router, prefix="", tags=["videos"])
    app.include_router(images.router, prefix="", tags=["images"])
    app.include_router(schedule.router, prefix="", tags=["schedule"])
    app.include_router(tasks.router, prefix="", tags=["tasks"])
    app.include_router(
        captions.router,
        prefix="",
        tags=[
            "captions",
        ],
    )

    return app


app = create_app()

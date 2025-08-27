from fastapi import FastAPI
from api.routers import captions, images, videos, schedule


def create_app():
    app = FastAPI(title="SocialSpark")

    # Register routers

    return app


app = create_app()

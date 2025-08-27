from infrastructure.celery_app import celery_app


# Example of a background task
@celery_app.task
def example_task(x, y):
    return x + y

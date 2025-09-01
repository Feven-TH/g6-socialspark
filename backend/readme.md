# SocialSpark Backend

This document provides instructions on how to set up and run the backend for SocialSpark.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **[Python 3.12.3 or later](https://www.python.org/downloads/)**
2.  **[MinIO](https://min.io/)** (Instructions are below on how to run with Docker)
3.  **[Redis](https://redis.io/)** (Instructions are below on how to run with Docker)
4.  **[Pixabay API key](https://pixabay.com/api/docs/)**
5.  **[Gemini API key](https://ai.google.dev/pricing)**

## Setup Instructions

Follow these steps to get the backend running on your local machine.

### 1. Clone the Repository

Clone the project into your desired projects directory.

```sh
git clone https://github.com/A2SV/g6-socialspark
```

### 2. Navigate to the Backend Directory

Change your current directory to the backend folder.

```sh
cd g6-socialspark/backend
```

### 3. Create and Activate a Python Virtual Environment

It's recommended to use a virtual environment to manage project dependencies.

-   **Create the virtual environment:**
    ```sh
    python3 -m venv .venv
    ```

-   **Activate the virtual environment:**
    ```sh
    source .venv/bin/activate
    ```

### 4. Install Dependencies

Install all the required Python packages from `requirements.txt`.
*(Make sure to activate your virtual environment before this step)*

```sh
pip install -r requirements.txt
```

### 5. Run MinIO with Docker

Use the following command to start a MinIO container.

```sh
sudo docker run -dp 9000:9000 -p 9001:9001 -e "MINIO_ROOT_USER=admin"  -e "MINIO_ROOT_PASSWORD=admin123" quay.io/minio/minio server /data --console-address ":9001"
```

### 6. Configure Environment Variables

Create a `.env` file from the example template and populate it with your credentials.

```sh
cp .env.example .env
```

### 7. Run the FastAPI Server

Start the main application server.

```sh
fastapi dev delivery/main.py
```

### 8. Run Redis with Docker

In a **separate terminal window**, run Redis using Docker.

```sh
sudo docker run -d --name redis -p 6379:6379 redis:latest
```

### 9. Run the Celery Worker

In another **separate terminal window**, start the Celery background worker.

```sh
celery -A infrastructure.celery_app worker --loglevel=info
```

Now, you can naviagate to `localhost:8000/docs` to look at the swagger API documentation inorder to integrate it into your project. Make sure to create a bucket called `videos` in the webUI of MinIO found at `localhost:9001`


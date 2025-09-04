# SocialSpark Backend

This document provides instructions on how to set up and run the backend for SocialSpark.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **[Docker](https://docs.docker.com/get-docker/)** and **[Docker Compose](https://docs.docker.com/compose/install/)**
2.  **[Python 3.12.3 or later](https://www.python.org/downloads/)** (for manual setup)
3.  **[Pixabay API key](https://pixabay.com/api/docs/)**
4.  **[Gemini API key](https://ai.google.dev/pricing)**
5.  **[Freesound API key](https://freesound.org/docs/api/)**
6. **[Ayrshare API Key](https://www.ayrshare.com/)**  
  SocialSpark uses Ayrshare to publish image-only posts to social media platforms (Instagram, Facebook,  etc.), and users must link their accounts via the Ayrshare dashboard.

   1. Go to [Ayrshare Dashboard](https://app.ayrshare.com/auth/register) and create a free account.  
   2. After signing in, navigate to **API Key** in your Ayrshare dashboard.  
   3. Copy your API key and paste it into your `.env` file.



## Getting Started (Docker - Recommended)

This is the easiest way to get the application running with a single command.

### 1. Clone the Repository

```sh
git clone https://github.com/A2SV/g6-socialspark
cd g6-socialspark/backend
```

### 2. Configure Environment Variables

Create a `.env` file from the example template.

```sh
cp .env.example .env
```

Open the `.env` file and populate it with your API keys. **Important:** You must also update the following lines to use the Docker service names instead of `localhost`:

```properties
# Change this
CELERY_BROKER_URI=redis://localhost:6379/0
CELERY_BACKEND_URI=redis://localhost:6379/0
MINIO_ENDPOINT=http://localhost:9000

# To this
CELERY_BROKER_URI=redis://redis:6379/0
CELERY_BACKEND_URI=redis://redis:6379/0
MINIO_ENDPOINT=http://minio:9000
```

### 3. Run with Docker Compose

Build and start all the services (FastAPI web server, Redis, MinIO, Celery Worker, and Celery Beat).

```sh
sudo docker compose build # (only the first time you run it)
sudo docker compose up 
```

The application will be available at `http://localhost:8000`, and the MinIO console will be at `http://localhost:9001`.

### 4. Create MinIO Bucket

After starting the services, navigate to the MinIO console at `http://localhost:9001`, log in with the credentials from your `.env` file, and create a new bucket named `videos`.

---

## Manual Setup Instructions

Follow these steps if you prefer to run the services manually without Docker Compose.

### 1. Clone and Set Up Environment

```sh
# Clone the repository
git clone https://github.com/A2SV/g6-socialspark
cd g6-socialspark/backend

# Create and activate a Python virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure Environment Variables

Create and populate your `.env` file. Make sure the URIs point to `localhost`.

```sh
cp .env.example .env
```

### 3. Run Dependent Services

You will need to run MinIO and Redis in separate terminals.

-   **Run MinIO with Docker:**
    ```sh
    sudo docker run -dp 9000:9000 -p 9001:9001 -e "MINIO_ROOT_USER=admin"  -e "MINIO_ROOT_PASSWORD=admin123" quay.io/minio/minio server /data --console-address ":9001"
    ```
-   **Run Redis with Docker:**
    ```sh
    sudo docker run -d --name redis -p 6379:6379 redis:latest
    ```

### 4. Run the Application

You will need three separate terminals for the FastAPI server and the Celery services.

-   **Terminal 1: Run the FastAPI Server**
    ```sh
    fastapi dev delivery/main.py
    ```
-   **Terminal 2: Run the Celery Worker**
    ```sh
    celery -A infrastructure.celery_app worker --loglevel=info
    ```
-   **Terminal 3: Run Celery Beat (Scheduler)**
    ```sh
    celery -A infrastructure.celery_app beat --loglevel=info
    ```

The application will be available at `http://localhost:8000`. Remember to create the `videos` bucket in MinIO.


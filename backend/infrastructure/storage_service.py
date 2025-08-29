import boto3
import os
from dotenv import load_dotenv
from typing import BinaryIO

load_dotenv()

s3_client = boto3.client(
    "s3",
    endpoint_url=os.getenv("MINIO_ENDPOINT"),
    aws_access_key_id=os.getenv("MINIO_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("MINIO_ACCESS_KEY"),
)

def upload_file(file: BinaryIO, object_name: str, bucket_name: str) -> str:
    """
    Uploads a binary file to an S3 bucket.
    """
    try:
        s3_client.upload_fileobj(file, bucket_name, object_name)
        return object_name
    except Exception as e:
        raise Exception(f"Failed to upload file: {e}")

def get_download_url(object_name: str, bucket_name: str) -> str:
    """
    Generates a presigned URL for downloading a file from an S3 bucket.
    """
    try:
        url = s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": bucket_name, "Key": object_name},
            ExpiresIn=3600,
        )
        return url
    except Exception as e:
        raise Exception(f"Failed to generate download URL: {e}")
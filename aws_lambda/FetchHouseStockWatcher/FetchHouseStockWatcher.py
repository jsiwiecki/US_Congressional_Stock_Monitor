import os
from typing import Dict, Optional, Any, Union, cast
import requests
import json
from datetime import datetime
import boto3
from botocore.exceptions import ClientError

class StockWatcherAPI:
    """
    A class to interact with a Stock Watcher API, fetch data,
    save it to a JSON file, and upload it to Amazon S3.
    """

    def __init__(self, url: str):
        """
        Initialize the StockWatcherAPI with the API URL.

        :param url: The URL of the Stock Watcher API.
        """
        self.url = url
        self.current_data = datetime.now().strftime("%Y-%m-%d")
        self.file_name = f"{self.current_data}_results.json"

    def fetch_data(self) -> Optional[Dict[str, Union[str, Any]]]:
        """
        Fetch data from the Stock Watcher API.

        :return: A dictionary containing the fetched JSON data if successful, None otherwise.
        """
        try:
            response = requests.get(self.url)

            if response.status_code != 200:
                print("Request failed.")
                return None

            data = cast(Dict[str, Union[str, Any]], response.json())
            return data
        except requests.exceptions.RequestException as e:
            print(f"Request failed with error: {e}")
            return None

    def save_data_to_file(self, data: Optional[Dict[str, Any]]) -> None:
        """
        Save the fetched data to a JSON file.

        :param data: The dictionary containing the data to save.
        """
        file_path = f"/tmp/{self.file_name}"

        if not data:
            print("No data to save.")
            return

        try:
            with open(file_path, "w") as outputfile:
                json.dump(data, outputfile)
        except IOError as e:
            print(f"Error saving data to file: {e}")

    def upload_to_s3(self, bucket_name: Optional[str], s3_key: Optional[str]) -> None:
            """
            Upload the JSON file to the specified Amazon S3 bucket.

            :param bucket_name: The name of the S3 bucket to upload the file to.
            :param s3_key: The S3 object key to use for the uploaded file.
            """
            if not bucket_name or not s3_key:
                return

            file_path = f"/tmp/{self.file_name}"

            try:
                s3_client = boto3.client('s3')
                s3_client.upload_file(file_path, bucket_name, s3_key)
                print(f"Successfully uploaded {file_path} to S3 bucket {bucket_name}")
            except ClientError as e:
                print(f"Error uploading file to S3 bucket: {e}")

def lambda_handler(event: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    """
    Fetch data from the Stock Watcher API, save it to a JSON file,
    and upload the file to an Amazon S3 bucket.

    :param event: The AWS Lambda event object (not used in this handler).
    :param context: The AWS Lambda context object (not used in this handler).
    :return: A dictionary containing the HTTP status code and response body.
    """
    url = os.getenv("STOCK_WATCHER_API_URL")

    if not url:
        return {
            "statusCode": 500,
            "body": "Environment variable STOCK_WATCHER_API_URL not set"
        }

    senate_stock_watcher = StockWatcherAPI(url)
    data = senate_stock_watcher.fetch_data()

    if data:
        bucket_name = os.getenv("S3_BUCKET_NAME")
        if not bucket_name:
            return {
                "statusCode": 500,
                "body": "Environment variable S3_BUCKET_NAME not set"
            }

        senate_stock_watcher.save_data_to_file(data)

        s3_key = f"raw/{senate_stock_watcher.file_name}"
        senate_stock_watcher.upload_to_s3(bucket_name, s3_key)

    return {
        "statusCode": 200,
        "body": "Data fetched from API and saved to S3"
    }
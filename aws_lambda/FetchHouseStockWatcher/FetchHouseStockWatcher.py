import os
import requests
import json
from datetime import datetime
import boto3

class StockWatcherAPI:
    def __init__(self, url):
        self.url = url
        self.current_data = datetime.now().strftime("%Y-%m-%d")
        self.file_name = f"{self.current_data}_results.json"

    def fetch_data(self):
        try:
            response = requests.get(self.url)

            if response.status_code != 200:
                print("Request failed.")
                return None

            data = response.json()
            return data
        except requests.exceptions.RequestException as e:
            print(f"Request failed with error: {e}")
            return None

    def save_data_to_file(self, data):
        file_path = f"/tmp/{self.file_name}"

        if not data:
            print("No data to save.")
            return

        try:
            with open(file_path, "w") as outputfile:
                json.dump(data, outputfile)
        except IOError as e:
            print(f"Error saving data to file: {e}")

    def upload_to_s3(self, bucket_name, s3_key):
        file_path = f"/tmp/{self.file_name}"

        try:
            s3_client = boto3.client('s3')
            s3_client.upload_file(file_path, bucket_name, s3_key)
            print(f"Successfully uploaded {file_path} to S3 bucket {bucket_name}")
        except Exception as e:
            print(f"Error uploading file to S3 bucket: {e}")

def lambda_handler(event, context):
    url = os.getenv("STOCK_WATCHER_API_URL")
    senate_stock_watcher = StockWatcherAPI(url)
    data = senate_stock_watcher.fetch_data()
    senate_stock_watcher.save_data_to_file(data)

    if data:
        bucket_name = os.getenv("S3_BUCKET_NAME")
        s3_key = f"data/{senate_stock_watcher.file_name}"
        senate_stock_watcher.upload_to_s3(bucket_name, s3_key)

    return {
        "statusCode": 200,
        "body": "Data fetched from API and saved to S3"
    }
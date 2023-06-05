import json
import requests
import boto3
import os

def fetch_data(api_url):
    response = requests.get(api_url)
    if response.status_code != 200:
        raise Exception(f"Failed to fetch data. API returned status {response.status_code}")
    return response.json()

def save_to_s3(data, s3_bucket, s3_key):
    s3 = boto3.client("s3")
    s3.put_object(Bucket=s3_bucket, Key=s3_key, Body=json.dumps(data))

def lambda_handler(event, context):
    api_url = "https://housestockwatcher.com/api"

    data = fetch_data(api_url)

    s3_bucket = os.environ["S3_BUCKET_NAME"]
    s3_key = "house_stock_watcher_data.json"
    save_to_s3(data, s3_bucket, s3_key)

    return {
        "statusCode": 200,
        "body": json.dumps("Data fetched from HouseStockWatcher API and saved to S3")
    }
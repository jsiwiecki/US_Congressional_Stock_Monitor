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
        response = requests.get(self.url)
        
        if response.status_code != 200:
            print("request failed.")
            return False

        data = response.json()
        return data
    
    def save_data_to_file(self, data):
        file_name = f"{self.current_data}_results.json"

        with open(file_name, "w") as outputfile:
            json.dump(data, outputfile)



def main():
    senate_stock_watcher = StockWatcherAPI("https://senate-stock-watcher-data.s3-us-west-2.amazonaws.com/aggregate/all_transactions.json")
    data = senate_stock_watcher.fetch_data()
    
    if data:
        senate_stock_watcher.save_data_to_file(data)
        s3_client = boto3.client('s3')
        bucket_name = os.getenv("S3_BUCKET_NAME")
        s3_key = f"{senate_stock_watcher.file_name}"
        s3_client.upload_file(senate_stock_watcher.file_name, bucket_name, s3_key)


if __name__ == "__main__":
    main()
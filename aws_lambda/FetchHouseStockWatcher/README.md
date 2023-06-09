# FetchHouseStockWatcher

This function fetches aggregated data about all transactions from `https://senate-stock-watcher-data.s3-us-west-2.amazonaws.com`

## Installation
0. Install required libraries
`pip install -r requirements.txt`

1. Zip needed libraries
`zip -r ../deployment_package.zip .`

2. Zip zipped libs with function itself
`zip -g deployment_package.zip FetchHouseStockWatcher.py`

3. Upload it to AWS Lambda. Remember to adjust Handler:
`<NameOfScript>.<NameOfMainFunction>`

4. Add environmental variables to AWS Lambda: 
`S3_BUCKET_NAME`
`STOCK_WATCHER_API_URL`

5. This script for AWS Lambda needs proper permissions to be able to save file in S3

6. Setup a trigger / frequence to fetch data by AWS Lambda function.

# FetchHouseStockWatcher

This function fetches aggregated data about all transactions from `https://senate-stock-watcher-data.s3-us-west-2.amazonaws.com`

## Installation
1. Zip needed libraries
`zip -r ../deployment_package.zip .`

2. Zip zipped libs with function itself
`zip -g deployment_package.zip FetchHouseStockWatcher.py`

3. Upload it to AWS Lambda. Remember to adjust Handler:
`<NameOfScript>.<NameOfMainFunction>`

4. This script for AWS Lambda needs proper permissions to be able to save file in S3
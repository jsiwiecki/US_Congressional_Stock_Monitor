# Project Title: "Congressional Stock Monitor"

## Project Description:

This is a data-driven application that retrieves, stores, analyzes, and visualizes U.S. Congress members' stock transactions, enabling users to see the trading habits of lawmakers and possibly uncover insightful patterns.

## Main Components:
This project is build based on servesless architecture. Main components:
1. AWS Lambda 
2. Python script
3. Snowflake (Stored Procedures, Tasks, Stages, Streams)

#### 1. Data Acquisition 

#### AWS Lambda - FetchHouseStockWatcher
Uses the U.S. Congress Stock Transactions API to retrieve the data of all transactions. 
Implemented by an AWS Lambda function which makes requests to this API regularly.

Function is located in: `aws_lambda/FetchHouseStockWatcher`

#### 2. Data Storage

#### S3 & Snowflake
Results of data fetching is saved in S3 in JSON format. Snowflake is used as data warehouse. It's integrated with S3 and process data from External Table to technical tables to eventually store data in traditional tables. Plus streams help to track changes in the data.


#### TBD:
#### Data Processing

Data Automation

Data Visualization

Alerts


## How to run?

### AWS LAMBDA
In AWS Lambda following function is used:
- FetchHouseStockWatcher

This function fetches aggregated data about all transactions from `https://senate-stock-watcher-data.s3-us-west-2.amazonaws.com`

#### Installation
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

### SNOWFLAKE
1. Run scripts in `db_scripts`
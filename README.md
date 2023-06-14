# Project Title: "Congressional Stock Monitor"

## Project Description:

This is a data-driven application that retrieves, stores, analyzes, and visualizes U.S. Congress members' stock transactions, enabling users to see the trading habits of lawmakers and possibly uncover insightful patterns.

## Main Components:
Main components:
1. AWS Lambda 
2. Python script
3. Snowflake (Stored Procedures, Tasks, Stages, Streams)
4. AWS S3
5. AWS Secret Manager 

### 1. Data Acquisition 

#### AWS Lambda - FetchHouseStockWatcher
Uses the U.S. Congress Stock Transactions API to retrieve the data of all transactions. 
Implemented by an AWS Lambda function which makes requests to this API regularly.

Function with its README is located in: `aws_lambda/FetchHouseStockWatcher`

#### AWS Lambda - SaveFetchDate
This function saves in DWH date of fetching data from external source. 
This function has it's own docker image for needs of runtime due to dependency issues.

Function with its README is located in: `aws_lambda/SaveFetchDate`


### 2. Data Storage

#### S3
Results of data fetching is saved in S3 in JSON format in `RAW` folder. 
After transformations done by Spark app data is moved to `DATA` folder.

#### Snowflake
Snowflake is used as data warehouse. It's integrated with S3. Has stages that refer to RAW layer and DATA layer with already transformed data by Spark application.
Snowflakes DWH consist of two schemas (STG_DWH for staging data and CORE_DWH as final form of data to store all the data in traditional tables). The flow in Snowflake is based on Stored Procedures and Tasks. It process data from External Table to STG_DWH tables to eventually store data in final location. Additionally stored procedures are keeping save to avoid data duplication when data is moved from STG_DWH to CORE_DWH.

#### Spark Application
This application reads data from `RAW` location in S3. Do necessary transformations and returns a final data to `DATA` in S3. It obtaines secrets from AWS Secrets Manager and runs from Docker container.


### TO DO:
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




### CONCLUSIONS:
- The whole structure of ETL can be better planned. Probably all the transformations can be done in Spark application which could eventually save data to Snowflake tables with CORE_DWH schema. However, this project was done with a priority to get to know as much tools as possible at once. With that purpose in mind this project was successfull.
- SaveFetchDate function is pointless from a bigger perspective. It could be an element of another Lambda Function or a part of a Spark application. However, it was extremely tempting to create an AWS Lambda function with its docker container as its runtime. Again, taking into consideration this point of perspective, project was successfull. However, from architectural, usability and many more perspectives it was completely pointless.
- The whole Spark application could be written with in mind Design Pattern like Fasade and Strategy. It would need to be investigated.
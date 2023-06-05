# Project Title: "Congressional Stock Monitor"

## Project Description:

This is a data-driven application that retrieves, stores, analyzes, and visualizes U.S. Congress members' stock transactions, enabling users to see the trading habits of lawmakers and possibly uncover insightful patterns.

## Main Components:

### 1. Data Acquisition 

#### FetchHouseStockWatcher
Uses the U.S. Congress Stock Transactions API to retrieve the data of all transactions. 
Implemented by an AWS Lambda function which makes requests to this API regularly.

Function is located in: `aws_lambda/FetchHouseStockWatcher`

### 2. Data Storage
1. S3 & Snowflake
Results of data fetching is saved in S3 in JSON format. Snowflake is used as data warehouse. It's integrated with S3 and process data from External Table to technical tables to eventually store data in traditional tables. Plus streams help to track changes in the data.


### TBD:
Data Processing

Data Automation

Data Visualization

Alerts
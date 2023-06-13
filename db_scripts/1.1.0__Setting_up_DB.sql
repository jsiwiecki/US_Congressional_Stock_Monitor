create database if not EXISTS THORGAL;
use database THORGAL;
CREATE SCHEMA IF NOT EXISTS CORE_DWH;
CREATE SCHEMA IF NOT EXISTS STG_DWH;

use schema STG_DWH;

// S3 Integration
CREATE OR REPLACE STORAGE INTEGRATION aws_s3_integration
type = external_stage
storage_provider= 'S3'
enabled=true
storage_aws_role_arn='arn:aws:iam::<YOUR_IAM>:role/<YOUR_ROLE>'
storage_allowed_locations=('s3://<NAME_OF_YOUR_BUCKET>/');

// File format for JSON
create or replace file format my_json_format
type='JSON'
STRIP_OUTER_ARRAY = TRUE;

// Stage for Raw data in S3
create or replace stage s3_raw_data
storage_integration = aws_s3_integration
file_format = my_json_format
url = 's3://<NAME_OF_YOUR_BUCKET>/raw';

// Stage for Transformed data in S3
create or replace stage s3_transformed
storage_integration = aws_s3_integration
file_format = my_json_format
url = 's3://<NAME_OF_YOUR_BUCKET>/data';
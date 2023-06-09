from pyspark.sql import SparkSession
import os

# Set AWS credentials and region
access_key = os.environ['AWS_ACCESS_KEY_ID']
secret_key = os.environ['AWS_SECRET_ACCESS_KEY']

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("Test S3 Read Parquet") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
    .getOrCreate()

# Set the s3_input_path
s3_input_path = "s3a://snowflakelabbucket/data/2023-06-04_results.json"

# Read data from S3
print("Reading Parquet data from S3...")
df = spark.read.json(s3_input_path)
print("Parquet data read successfully")

df.show()

# Print the count of records
print(f"Total records found: {df.count()}")

# Stop SparkSession
spark.stop()
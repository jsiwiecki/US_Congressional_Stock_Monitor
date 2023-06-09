import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when

print("####### Starting APP #######")

access_key_id = os.environ['AWS_ACCESS_KEY_ID']
secret_key = os.environ['AWS_SECRET_ACCESS_KEY']
s3_bucket_name = os.environ['S3_BUCKET_NAME']

spark = SparkSession.builder \
    .appName("S3 transformation") \
    .config("spark.executor.memory", "2g") \
    .config("spark.driver.memory", "2g") \
    .config("spark.driver.cores", "2") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
    .config("spark.hadoop.fs.s3a.access.key", access_key_id) \
    .config("spark.hadoop.fs.s3a.secret.key", secret_key) \
    .getOrCreate()

#logger = spark._jvm.org.apache.log4j
#logger.LogManager.getLogger("org").setLevel(logger.Level.DEBUG)


s3_input_path = f"s3a://{s3_bucket_name}/data/2023-06-04_results.json"
s3_output_path = f"s3a://{s3_bucket_name}/transformed/"

df = spark.read.json(s3_input_path)

df = df.withColumn('industries', when(col('industry').isNull(), 'unknown').otherwise(col('industry')))

df.show()

df.write \
    .json(s3_output_path, mode="overwrite")

spark.stop()
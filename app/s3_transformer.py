import os
import json
import boto3
from datetime import datetime
from botocore.exceptions import ClientError
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql.functions import unix_timestamp, from_unixtime, col, when, expr

from schema import INPUT_SCHEMA
from constraints import DATES_TO_TRANSFORM, NULL_VAL_MAPPINGS



class S3TransformationApp:
    """
    A PySpark application that reads JSON data from an S3 bucket, performs a transformation,
    and writes the results back to the same S3 bucket as a JSON file.
    """

    def __init__(self, access_key_id: str, secret_key: str, s3_bucket_name: str):
        """
        Initialize the S3TransformationApp with AWS access keys and an S3 bucket name.

        :param access_key_id: The AWS Access Key ID.
        :param secret_key: The AWS Secret Access Key.
        :param s3_bucket_name: The name of the S3 bucket to read/write data from/to.
        """
        self.access_key_id = access_key_id
        self.secret_key = secret_key
        self.s3_bucket_name = s3_bucket_name
        self.spark = self.setup_spark_session()


    def setup_spark_session(self) -> SparkSession:
        """
        Set up a new SparkSession with the necessary configurations.
  
        :return: The created SparkSession instance.
        """
        spark = SparkSession.builder \
            .appName("S3 transformation") \
            .config("spark.executor.memory", "2g") \
            .config("spark.driver.memory", "2g") \
            .config("spark.driver.cores", "2") \
            .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
            .config("spark.hadoop.fs.s3a.access.key", self.access_key_id) \
            .config("spark.hadoop.fs.s3a.secret.key", self.secret_key) \
            .getOrCreate()

        return spark
    
    def results_filename_path_creator(self, folder):
        """
        TO DO: date should be received from Lambda
        """
        date = datetime.now().strftime("%Y-%m-%d")
        filepath = f"{folder}/{date}_results.json"

        return filepath

    def read_data_from_s3(self, schema, filepath: str) -> DataFrame:
        """
        Read JSON data from the given S3 path.
        
        :param filepath: The path to the JSON file within the specified S3 bucket.
        :return: A DataFrame containing the JSON data.
        """
        s3_input_path = f"s3a://{self.s3_bucket_name}/{filepath}"
        return self.spark.read.json(s3_input_path, schema=schema)

    def clean_nulls(self, df: DataFrame) -> DataFrame:
        """
        Perform a cleaning on the given DataFrame.
        
        :param df: The input DataFrame.
        :return: The transformed DataFrame.
        """
        transformed_df = df.fillna(NULL_VAL_MAPPINGS)

        for column in transformed_df.columns:
            transformed_df = transformed_df.withColumn(column, when(col(column) == 'N/A', 'Unknown').otherwise(col(column))) \
                                            .withColumn(column, when(col(column) == '--', '').otherwise(col(column))) \
                                            .withColumn('asset_description', expr(f"REGEXP_REPLACE({column}, '<.*?>', '')")) \
                                            
        return transformed_df

    def transform_date_format(self,  columns, df: DataFrame) -> DataFrame:
        """
        Transforms format of a date from MM/dd/yyyy to yyyy-MM-dd
        :param columns: List with columns to be transformed
        :param df: The input DataFrame.        
        :return: The transformed DataFrame.
        """            
        input_date_format = "MM/dd/yyyy"
        output_date_format = "yyyy-MM-dd"
        
        transformed_df = df

        for column_name in columns:
            transformed_df = transformed_df.withColumn(
                column_name, 
                from_unixtime(unix_timestamp(df[column_name], input_date_format), output_date_format)
            )

        return transformed_df

    def write_data_to_s3(self, df: DataFrame, filepath: str) -> None:
        """
        Write the given DataFrame as a JSON file to the specified S3 path. 
        
        :param df: The DataFrame to be written to S3.
        :param filepath: The destination path within the specified S3 bucket.
        """
        s3_output_path = f"s3a://{self.s3_bucket_name}/{filepath}/"
        df.write.json(s3_output_path, mode="overwrite")

    def run(self) -> None:
        """
        Execute the S3TransformationApp by reading data from S3,
        transforming the DataFrame, and writing the results back to S3.
        """

        raw_reading_path = self.results_filename_path_creator("raw")

        df = self.read_data_from_s3(INPUT_SCHEMA, raw_reading_path)
        transformed_df = self.clean_nulls(df)
        transformed_df = self.transform_date_format(DATES_TO_TRANSFORM, transformed_df)

        self.write_data_to_s3(transformed_df, "data")

        self.spark.stop()

def get_secrets():

    secret_name = "snowflake_access"
    region_name = "eu-central-1"

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    secret_dict = json.loads(secret)

    access_key_id = secret_dict["AWS_ACCESS_KEY_ID"]
    secret_key = secret_dict["AWS_SECRET_ACCESS_KEY"]
    s3_bucket_name = secret_dict["S3_BUCKET_NAME"]

    return access_key_id, secret_key, s3_bucket_name


if __name__ == "__main__":
    """
    Initialize and run the S3TransformationApp with AWS credentials and an S3 bucket name.
    """
    access_key_id, secret_key, s3_bucket_name = get_secrets()

    app = S3TransformationApp(access_key_id, secret_key, s3_bucket_name)

    app.run()
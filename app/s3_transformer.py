import os
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql.functions import col, when

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

    def read_data_from_s3(self, filepath: str) -> DataFrame:
        """
        Read JSON data from the given S3 path.
        
        :param filepath: The path to the JSON file within the specified S3 bucket.
        :return: A DataFrame containing the JSON data.
        """
        s3_input_path = f"s3a://{self.s3_bucket_name}/{filepath}"
        return self.spark.read.json(s3_input_path)

    def transform_data(self, df: DataFrame) -> DataFrame:
        """
        Perform a transformation on the given DataFrame.
        
        :param df: The input DataFrame.
        :return: The transformed DataFrame.
        """
        for column in dataframe.columns:
            dataframe = dataframe.withColumn(column, when(col(column) == '', 'NA').otherwise(col(column)))

    def write_data_to_s3(self, df: DataFrame, filepath: str) -> None:
        """
        Write the given DataFrame as a JSON file to the specified S3 path. 
        
        :param df: The DataFrame to be written to S3.
        :param filepath: The destination path within the specified S3 bucket.
        """
        s3_output_path = f"s3a://{self.s3_bucket_name}/{filepath}"
        df.write.json(s3_output_path, mode="overwrite")

    def run(self) -> None:
        """
        Execute the S3TransformationApp by reading data from S3,
        transforming the DataFrame, and writing the results back to S3.
        """
        input_path = "raw/2023-06-04_results.json"
        output_path = "transformed/"

        df = self.read_data_from_s3(input_path)

        transformed_df = self.transform_data(df)

        self.write_data_to_s3(transformed_df, output_path)

        self.spark.stop()

if __name__ == "__main__":
    """
    Initialize and run the S3TransformationApp with AWS credentials and an S3 bucket name.
    """
    access_key_id = os.environ["AWS_ACCESS_KEY_ID"]
    secret_key = os.environ["AWS_SECRET_ACCESS_KEY"]
    s3_bucket_name = os.environ["S3_BUCKET_NAME"]

    app = S3TransformationApp(access_key_id, secret_key, s3_bucket_name)
    app.run()
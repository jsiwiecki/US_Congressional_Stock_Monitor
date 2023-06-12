from pyspark.sql.types import StructField, StructType, StringType

INPUT_SCHEMA = StructType([
    StructField("amount", StringType(), True),
    StructField("asset_description", StringType(), True),
    StructField("asset_type", StringType(), True),
    StructField("comment", StringType(), True),
    StructField("disclosure_date", StringType(), True),
    StructField("industry", StringType(), True),
    StructField("owner", StringType(), True),
    StructField("party", StringType(), True),
    StructField("ptr_link", StringType(), True),
    StructField("sector", StringType(), True),
    StructField("senator", StringType(), True),
    StructField("state", StringType(), True),
    StructField("ticker", StringType(), True),
    StructField("transaction_date", StringType(), True),
    StructField("type", StringType(), True),
])
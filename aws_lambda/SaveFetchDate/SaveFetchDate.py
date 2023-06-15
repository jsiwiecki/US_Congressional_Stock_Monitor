import os
from sqlalchemy import create_engine, insert
from datetime import datetime


class SaveFetchDate:
    """
    A class to connect to Snowflake and saves a filename in a proper table.
    """

    def __init__(self, user, password, account_identifier, database_name, schema_name, role_name, warehouse_name):
        self.user = user
        self.password = password
        self.account_identifier = account_identifier
        self.database_name = database_name
        self.schema_name = schema_name
        self.role_name = role_name
        self.warehouse_name = warehouse_name

    def establish_connection(self):
        conn_string = f"snowflake://{self.user}:{self.password}@{self.account_identifier}/{self.database_name}/{self.schema_name}?warehouse={self.warehouse_name}&role={self.role_name}"
        self.engine = create_engine(conn_string)
        self.connection = self.engine.connect()

        return self.connection

    def get_current_date(self):
        current_date = self.fetching_date = datetime.now().strftime("%Y-%m-%d")
        return current_date

    def insert_fetch_history(self, fetching_date):
        connection = self.connection
        insert_query = f"INSERT INTO {self.database_name}.{self.schema_name}.FETCH_HISTORY (fetching_date) VALUES ('{fetching_date}')"
        connection.execute(insert_query)
        print(f"Inserted {fetching_date} into FETCH_HISTORY")


    def close(self):
        self.connection.close()
        self.engine.dispose()


def lambda_handler(event, context):
    """
    Fetch data from the Stock Watcher API, save it to a JSON file,
    and upload the file to an Amazon S3 bucket.

    :param event: The AWS Lambda event object (not used in this handler).
    :param context: The AWS Lambda context object (not used in this handler).
    :return: A dictionary containing the HTTP status code and response body.
    """

    user = os.getenv("SNOWFLAKE_USER")
    password = os.getenv("SNOWFLAKE_PASSWORD")
    account_identifier = os.getenv("SNOWFLAKE_ACCOUNT")
    database_name = os.getenv("SNOWFLAKE_DATABASE")
    schema_name = os.getenv("SNOWFLAKE_SCHEMA")
    role_name = os.getenv("SNOWFLAKE_ROLE")
    warehouse_name = os.getenv("SNOWFLAKE_WAREHOUSE")

    snowflake = SaveFetchDate(user, password, account_identifier, database_name, schema_name, role_name, warehouse_name)
    current_date = snowflake.get_current_date()

    snowflake.establish_connection()
    snowflake.insert_fetch_history(current_date)

    snowflake.close()

    return {
        "statusCode": 200,
        "body": "Table updated with current fetching date"
    }

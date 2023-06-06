use schema CORE_DWH;

// Refreshes external table, nothing more
CREATE OR REPLACE PROCEDURE REFRESH_EXT_TABLE()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "ALTER EXTERNAL TABLE CORE_DWH.EXT_RAW_DATA REFRESH"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "External table CORE_DWH.EXT_RAW_DATA refreshed successfully!"
$$;

CREATE OR REPLACE PROCEDURE COPY_RAW_DATA()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "INSERT INTO STG_DWH.TRANSACTIONS (transaction_date, owner, ticker, asset_description, asset_type, type, amount, comment, party, state, industry, sector, senator, ptr_link, disclosure_date)" +
        "SELECT $1:transaction_date::DATE, $1:owner::STRING, $1:ticker::STRING, $1:asset_description::STRING, $1:asset_type::STRING, $1:type::STRING," +
        "$1:amount::STRING, $1:comment::STRING, $1:party::STRING, $1:state::STRING, $1:industry::STRING, $1:sector::STRING, $1:senator::STRING," +
        "$1:ptr_link::STRING, $1:disclosure_date::DATE " +
        "FROM CORE_DWH.TRANSACTIONS;"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "Data from EXTERNAL table with RAW data copied to STG_DWH.TRANSACTIONS successfully!";
$$;


CREATE OR REPLACE PROCEDURE clean_INGEST()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "DELETE FROM STG_DWH.TRANSACTIONS"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "Data from STG_DWH.TRANSACTIONS cleaned successfully!"
$$;

CREATE OR REPLACE PROCEDURE STG_TO_DWH()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  var insert_sql = `
    INSERT INTO CORE_DWH.TRANSACTIONS (
      transaction_date,
      owner,
      ticker,
      asset_description,
      asset_type,
      type,
      amount,
      comment,
      party,
      state,
      industry,
      sector,
      senator,
      ptr_link,
      disclosure_date
    )
    SELECT * FROM (
      SELECT
        transaction_date,
        owner,
        ticker,
        asset_description,
        asset_type,
        type,
        amount,
        comment,
        party,
        state,
        industry,
        sector,
        senator,
        ptr_link,
        disclosure_date
      FROM
        STG_DWH.TRANSACTIONS
      EXCEPT
      SELECT
        transaction_date,
        owner,
        ticker,
        asset_description,
        asset_type,
        type,
        amount,
        comment,
        party,
        state,
        industry,
        sector,
        senator,
        ptr_link,
        disclosure_date
      FROM
        CORE_DWH.TRANSACTIONS
    ) derived_query;
  `;

  snowflake.execute({ sqlText: insert_sql });
  return 'Unique rows copied from STG_DWH to CORE_DWH successfully.';
$$;

// One procedure to orchestrate
CREATE OR REPLACE PROCEDURE orchestrate_process()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  snowflake.execute({ sqlText: "CALL refresh_ext_table();" });
  snowflake.execute({ sqlText: "CALL COPY_RAW_DATA();" });
  snowflake.execute({ sqlText: "CALL RAW_FINAL_CHECK_COPY();" });
  snowflake.execute({ sqlText: "CALL clean_INGEST();" });
  return 'Three stored procedures completed successfully.';
$$;


// Task that runs every day at midnight
CREATE TASK daily_task_for_stored_procedures
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = 'USING CRON 0 0 * * * UTC'
AS
  CALL call_first_and_second();

ALTER TASK daily_task_for_stored_procedures RESUME;
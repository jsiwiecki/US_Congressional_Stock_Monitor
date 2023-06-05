use schema TECH_DBO;

CREATE OR REPLACE PROCEDURE COPY_EXT_TECH_DBO()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "INSERT INTO TECH_DBO.INGEST (transaction_date, owner, ticker, asset_description, asset_type, type, amount, comment, party, state, industry, sector, senator, ptr_link, disclosure_date)" +
        "SELECT $1:transaction_date::DATE, $1:owner::STRING, $1:ticker::STRING, $1:asset_description::STRING, $1:asset_type::STRING, $1:type::STRING," +
        "$1:amount::STRING, $1:comment::STRING, $1:party::STRING, $1:state::STRING, $1:industry::STRING, $1:sector::STRING, $1:senator::STRING," +
        "$1:ptr_link::STRING, $1:disclosure_date::DATE " +
        "FROM CORE_DWH.EXT_RAW_DATA;"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "Data from EXTERNAL table copied to TECH_DBO.INGEST successfully!";
$$;
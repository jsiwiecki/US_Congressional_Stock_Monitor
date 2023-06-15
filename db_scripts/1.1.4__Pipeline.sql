use schema CORE_DWH;

// Refreshes external table, nothing more
CREATE OR REPLACE PROCEDURE refresh_ext_table_transformed()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "ALTER EXTERNAL TABLE THORGAL.STG_DWH.EXT_DATA REFRESH"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "External table CORE_DWH.EXT_DATA refreshed successfully!"
$$;

CREATE OR REPLACE PROCEDURE copy_EXT_STG()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "INSERT INTO STG_DWH.ALL_DATA (transaction_date, owner, ticker, asset_description, asset_type, type, amount, comment, party, state, industry, sector, senator, ptr_link, disclosure_date)" +
        "SELECT $1:transaction_date::DATE, $1:owner::STRING, $1:ticker::STRING, $1:asset_description::STRING, $1:asset_type::STRING, $1:type::STRING," +
        "$1:amount::STRING, $1:comment::STRING, $1:party::STRING, $1:state::STRING, $1:industry::STRING, $1:sector::STRING, $1:senator::STRING," +
        "$1:ptr_link::STRING, $1:disclosure_date::DATE " +
        "FROM STG_DWH.EXT_DATA;"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "Data from EXTERNAL table from STG_DWH.EXT_DATA copied to STG_DWH.ALL_DATA successfully!";
$$;


CREATE OR REPLACE PROCEDURE STG_insert_new_senators()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  var insert_new_senators_sql = `
    INSERT INTO STG_DWH.STG_DIM_SENATOR (
      senator_name,
      party,
      state
    )
    SELECT DISTINCT
      s.senator,
      s.party,
      s.state
    FROM
      STG_DWH.ALL_DATA AS s
      LEFT JOIN STG_DWH.STG_DIM_SENATOR AS d
        ON s.senator = d.senator_name
    WHERE
      d.senator_id IS NULL;
  `;

  snowflake.execute({ sqlText: insert_new_senators_sql });
  return 'New senators inserted into STG_DIM_SENATOR table.';
$$;


CREATE OR REPLACE PROCEDURE STG_insert_new_industries()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  var insert_new_industries_sql = `
    INSERT INTO STG_DWH.STG_DIM_INDUSTRY (
      industry_name,
      sector
    )
    SELECT DISTINCT
      s.industry,
      s.sector
    FROM
      STG_DWH.ALL_DATA AS s
      LEFT JOIN STG_DWH.STG_DIM_INDUSTRY AS d
        ON s.industry = d.industry_name
        AND s.sector = d.sector
    WHERE
      d.industry_id IS NULL;
  `;

  snowflake.execute({ sqlText: insert_new_industries_sql });
  return 'New industries and sectors inserted into DIM_INDUSTRY table.';
$$;


CREATE OR REPLACE PROCEDURE STG_insert_transactions()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  var insert_transactions_sql = `
    INSERT INTO STG_DWH.STG_FACT_TRANSACTIONS (
      transaction_date,
      owner,
      ticker,
      asset_description,
      asset_type,
      type,
      amount,
      comment,
      ptr_link,
      disclosure_date,
      senator_id,
      industry_id
    ) 
    SELECT
      s.transaction_date,
      s.owner,
      s.ticker,
      s.asset_description,
      s.asset_type,
      s.type,
      s.amount,
      s.comment,
      s.ptr_link,
      s.disclosure_date,
      d_sen.senator_id,
      d_ind.industry_id
    FROM
      STG_DWH.STG_FACT_TRANSACTIONS AS s
      INNER JOIN STG_DWH.STG_DIM_SENATOR AS d_sen ON s.senator = d_sen.senator_name
      INNER JOIN STG_DWH.STG_DIM_INDUSTRY AS d_ind ON s.industry = d_ind.industry_name AND s.sector = d_ind.sector;
  `;

  snowflake.execute({ sqlText: insert_transactions_sql });
  return 'Transactions inserted into STG_FACT_TRANSACTIONS table.';
$$;





CREATE OR REPLACE PROCEDURE clean_INGEST()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "DELETE FROM STG_DWH.ALL_DATA"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "Data from STG_DWH.ALL_DATA cleaned successfully!"
$$;



// One procedure to orchestrate
CREATE OR REPLACE PROCEDURE orchestrate_process()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  snowflake.execute({ sqlText: "CALL refresh_ext_table_transformed();" });
  snowflake.execute({ sqlText: "CALL copy_EXT_STG();" });
  snowflake.execute({ sqlText: "CALL STG_insert_new_senators();" });
  snowflake.execute({ sqlText: "CALL STG_insert_new_industries();" });
  snowflake.execute({ sqlText: "CALL STG_insert_transactions();" });
  snowflake.execute({ sqlText: "CALL STG_DWH.ALL_DATA();" });
  snowflake.execute({ sqlText: "CALL clean_INGEST();" });
  return 'All stored procedures completed successfully.';
$$;

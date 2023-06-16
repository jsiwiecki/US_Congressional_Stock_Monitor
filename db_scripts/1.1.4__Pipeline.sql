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


// Clean STG_SENATORS
CREATE OR REPLACE PROCEDURE clean_STG_senators()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "DELETE FROM THORGAL.STG_DWH.STG_DIM_SENATOR"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "STG_DIM_SENATOR cleaned successfully!"
$$;


// Clean STG_DIM_INDUSTRY
CREATE OR REPLACE PROCEDURE clean_STG_industries()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "DELETE FROM THORGAL.STG_DWH.STG_DIM_INDUSTRY"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "STG_DIM_INDUSTRY cleaned successfully!"
$$;


// Clean STG_FACT_TRANSACTIONS
CREATE OR REPLACE PROCEDURE clean_STG_transactions()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command = "DELETE FROM THORGAL.STG_DWH.STG_FACT_TRANSACTIONS"

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "STG_FACT_TRANSACTIONS cleaned successfully!"
$$;


CREATE OR REPLACE PROCEDURE COPY_EXT_STG()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    var sql_command =
        "INSERT INTO STG_DWH.ALL_DATA (transaction_date, owner, ticker, asset_description, asset_type, type, amount, comment, party, state, industry, sector, senator, ptr_link, disclosure_date) " +
        "SELECT ext.transaction_date, ext.owner, ext.ticker, ext.asset_description, ext.asset_type, ext.type, ext.amount, ext.comment, ext.party, ext.state, ext.industry, ext.sector, ext.senator, ext.ptr_link, ext.disclosure_date " +
        "FROM (" +
            "SELECT " +
            "$1:transaction_date::DATE AS transaction_date, " +
            "$1:owner::STRING AS owner, " +
            "$1:ticker::STRING AS ticker, " +
            "$1:asset_description::STRING AS asset_description, " +
            "$1:asset_type::STRING AS asset_type, " +
            "$1:type::STRING AS type, " +
            "$1:amount::STRING AS amount, " +
            "$1:comment::STRING AS comment, " +
            "$1:party::STRING AS party, " +
            "$1:state::STRING AS state, " +
            "$1:industry::STRING AS industry, " +
            "$1:sector::STRING AS sector, " +
            "$1:senator::STRING AS senator, " +
            "$1:ptr_link::STRING AS ptr_link, " +
            "$1:disclosure_date::DATE AS disclosure_date " +
        "FROM STG_DWH.EXT_DATA " +
        ") AS ext " +
        "LEFT JOIN STG_DWH.ALL_DATA AS e " +
        "ON ext.transaction_date = e.transaction_date " +
        "AND ext.owner = e.owner " +
        "AND ext.ticker = e.ticker " +
        "AND ext.asset_description = e.asset_description " +
        "AND ext.asset_type = e.asset_type " +
        "AND ext.type = e.type " +
        "AND ext.amount = e.amount " +
        "AND ext.comment = e.comment " +
        "AND ext.party = e.party " +
        "AND ext.state = e.state " +
        "AND ext.industry = e.industry " +
        "AND ext.sector = e.sector " +
        "AND ext.senator = e.senator " +
        "AND ext.ptr_link = e.ptr_link " +
        "AND ext.disclosure_date = e.disclosure_date " +
        "WHERE e.transaction_date IS NULL;";

    var statement = snowflake.createStatement({sqlText: sql_command});
    statement.execute();
    return "Data from STG_DWH.EXT_DATA table copied to STG_DWH.ALL_DATA successfully!";
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
    SELECT
      s.SENATOR,
      s.PARTY,
      s.STATE
    FROM
      STG_DWH.ALL_DATA AS s;
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
    SELECT
      s.industry,
      s.sector
    FROM
      STG_DWH.ALL_DATA AS s;
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
      STG_DWH.ALL_DATA AS s
      INNER JOIN STG_DWH.STG_DIM_SENATOR AS d_sen ON s.senator = d_sen.senator_name
      INNER JOIN STG_DWH.STG_DIM_INDUSTRY AS d_ind ON s.industry = d_ind.industry_name AND s.sector = d_ind.sector;
  `;

  snowflake.execute({ sqlText: insert_transactions_sql });
  return 'Transactions inserted into STG_FACT_TRANSACTIONS table.';
$$;


CREATE OR REPLACE PROCEDURE senator_STG_DWH()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  var insert_senators_sql = `
    INSERT INTO CORE_DWH.DIM_SENATOR (
      senator_name,
      party,
      state
    )
    SELECT
      s.SENATOR_NAME,
      s.PARTY,
      s.STATE
    FROM
      STG_DWH.STG_DIM_SENATOR s;
  `;

  snowflake.execute({ sqlText: insert_senators_sql });
  return 'STG copied to CORE_DWH.';
$$;


CREATE OR REPLACE PROCEDURE industry_STG_DWH()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  var insert_senators_sql = `
    INSERT INTO CORE_DWH.DIM_INDUSTRY (
      industry_name,
      sector
    )
    SELECT DISTINCT
      s.industry_name,
      s.sector
    FROM
      STG_DWH.STG_DIM_INDUSTRY AS s
      ;
  `;

  snowflake.execute({ sqlText: insert_senators_sql });
  return 'STG_DIM_INDUSTRY copied to CORE_DWH.DIM_INDUSTRY.';
$$;


CREATE OR REPLACE PROCEDURE transactions_STG_DWH()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  var insert_senators_sql = `
        INSERT INTO CORE_DWH.FACT_TRANSACTIONS (
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
        SELECT 
          st.transaction_date, 
          st.owner, 
          st.ticker, 
          st.asset_description, 
          st.asset_type, 
          st.type, 
          st.amount, 
          st.comment, 
          st.party, 
          st.state, 
          st.industry, 
          st.sector, 
          st.senator, 
          st.ptr_link, 
          st.disclosure_date
        FROM
          THORGAL.STG_DWH.STG_FACT_TRANSACTIONS
      ;
  `;

  snowflake.execute({ sqlText: insert_senators_sql });
  return 'STG_DWH.STG_FACT_TRANSACTIONS copied to CORE_DWH.FACT_TRANSACTIONS.';
$$;


// One procedure to orchestrate
CREATE OR REPLACE PROCEDURE orchestrate_process()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
AS
$$
  snowflake.execute({ sqlText: "CALL refresh_ext_table_transformed();" });
  snowflake.execute({ sqlText: "CALL clean_STG_senators();" });
  snowflake.execute({ sqlText: "CALL clean_STG_industries();" });
  snowflake.execute({ sqlText: "CALL clean_STG_transactions();" });
  snowflake.execute({ sqlText: "CALL copy_EXT_STG();" });
  snowflake.execute({ sqlText: "CALL STG_insert_new_senators();" });
  snowflake.execute({ sqlText: "CALL STG_insert_new_industries();" });
  snowflake.execute({ sqlText: "CALL STG_insert_transactions();" });
  snowflake.execute({ sqlText: "CALL senator_STG_DWH();" });
  snowflake.execute({ sqlText: "CALL industry_STG_DWH();" });
  snowflake.execute({ sqlText: "CALL transactions_STG_DWH();" });
  return 'All stored procedures completed successfully.';
$$;

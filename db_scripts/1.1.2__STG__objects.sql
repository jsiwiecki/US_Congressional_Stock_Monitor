CREATE SCHEMA IF NOT EXISTS STG_DWH;

CREATE OR REPLACE TABLE STG_DWH.TRANSACTIONS(
    transaction_date DATE,
    owner VARCHAR,
    ticker VARCHAR,
    asset_description VARCHAR,
    asset_type VARCHAR,
    type VARCHAR,
    amount VARCHAR,
    comment VARCHAR,
    party VARCHAR,
    state VARCHAR,
    industry VARCHAR,
    sector VARCHAR,
    senator VARCHAR,
    ptr_link VARCHAR,
    disclosure_date DATE
);

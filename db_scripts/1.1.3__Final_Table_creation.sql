create sequence CORE_DWH.TRANSACTIONS_ID_SEQUENCE
    start = 1
    increment = 1;

CREATE OR REPLACE TABLE CORE_DWH.TRANSACTIONS(
    id number default CORE_DWH.TRANSACTIONS_ID_SEQUENCE.nextval,
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
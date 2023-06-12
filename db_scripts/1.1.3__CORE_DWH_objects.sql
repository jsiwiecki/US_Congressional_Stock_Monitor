/*
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
*/

use schema THORGAL.CORE_DWH;

CREATE OR REPLACE TABLE THORGAL.CORE_DWH.DIM_SENATOR (
    senator_id NUMBER AUTOINCREMENT,
    senator_name STRING,
    party STRING,
    state STRING,
    PRIMARY KEY(senator_id)
);

CREATE OR REPLACE TABLE THORGAL.CORE_DWH.DIM_INDUSTRY (
    industry_id NUMBER AUTOINCREMENT,
    industry_name STRING,
    sector STRING,
    PRIMARY KEY(industry_id)
);

CREATE OR REPLACE TABLE THORGAL.CORE_DWH.FACT_TRANSACTIONS (
    transaction_id NUMBER AUTOINCREMENT,
    transaction_date DATE,
    owner STRING,
    ticker STRING,
    asset_description STRING,
    asset_type STRING,
    type STRING,
    amount STRING,
    comment STRING,
    ptr_link STRING,
    disclosure_date DATE,
    senator_id NUMBER,
    industry_id NUMBER,
    FOREIGN KEY (senator_id) REFERENCES CORE_DWH.DIM_SENATOR(senator_id),
    FOREIGN KEY (industry_id) REFERENCES CORE_DWH.DIM_INDUSTRY(industry_id),
    PRIMARY KEY(transaction_id)
);

CREATE OR REPLACE TABLE THORGAL.CORE_DWH.FETCH_HISTORY (
    fetch_id NUMBER AUTOINCREMENT,
    fetching_date DATE,
    PRIMARY KEY(fetch_id)
);
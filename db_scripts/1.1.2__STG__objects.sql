use schema THORGAL.STG_DWH;

CREATE OR REPLACE TABLE THORGAL.STG_DWH.ALL_DATA(
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

CREATE OR REPLACE TABLE THORGAL.STG_DWH.STG_DIM_SENATOR (
    senator_id NUMBER AUTOINCREMENT,
    senator_name STRING,
    party STRING,
    state STRING,
    PRIMARY KEY(senator_id)
);

CREATE OR REPLACE TABLE THORGAL.STG_DWH.STG_DIM_INDUSTRY (
    industry_id NUMBER AUTOINCREMENT,
    industry_name STRING,
    sector STRING,
    PRIMARY KEY(industry_id)
);


CREATE OR REPLACE TABLE THORGAL.STG_DWH.STG_FACT_TRANSACTIONS (
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
    FOREIGN KEY (senator_id) REFERENCES THORGAL.STG_DWH.STG_DIM_SENATOR(senator_id),
    FOREIGN KEY (industry_id) REFERENCES THORGAL.STG_DWH.STG_DIM_INDUSTRY(industry_id),
    PRIMARY KEY(transaction_id)
);


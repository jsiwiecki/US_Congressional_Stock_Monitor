CREATE SCHEMA IF NOT EXISTS TECH_DBO;

create sequence INGEST_ID_SEQUENCE
    start = 1
    increment = 1;


CREATE OR REPLACE TABLE TECH_DBO.INGEST(
    id number default INGEST_ID_SEQUENCE.nextval,
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


create sequence ID_SEQUENCE
    start = 1
    increment = 1;


CREATE TABLE IF NOT EXISTS TECH_DBO.INGEST_LOG (
    id number default ID_SEQUENCE.nextval,
    ingestion_date DATE
);

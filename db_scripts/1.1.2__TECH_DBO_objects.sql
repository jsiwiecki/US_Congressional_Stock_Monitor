CREATE SCHEMA IF NOT EXISTS TECH_DBO;

CREATE TABLE IF NOT EXISTS TECH_DBO.INGEST(
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

CREATE TABLE IF NOT EXISTS TECH_DBO.INGEST_LOG (
    id number default ID_SEQUENCE.nextval,
    ingestion_date DATE
);

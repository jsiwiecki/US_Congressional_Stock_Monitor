use schema CORE_DWH;

CREATE OR REPLACE STREAM
  raw_data
  ON EXTERNAL TABLE CORE_DWH.EXT_RAW_DATA
  INSERT_ONLY = true;
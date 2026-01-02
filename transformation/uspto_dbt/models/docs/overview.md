{% docs __overview__ %}

# USPTO M&A Analysis Pipeline

## 🎯 Project Goal
To analyze Mergers & Acquisitions (M&A) activity by parsing semi-structured XML data from the US Patent & Trademark Office (USPTO).

## 🏗 Architecture
1.  **Ingest:** Python script downloads ZIP files to `downloads/`.
2.  **Load:** Airflow pushes raw data into **Snowflake**.
3.  **Transform:** **dbt** parses XML into structured Star Schema (Facts & Dimensions).
4.  **Analyze:** Final reports identify companies acquiring the most patents.

## 🔑 Key Tables
* [dim_assignees](#!/model/model.uspto_dbt.dim_assignees): Companies involved in the transactions.
* [fct_assignment_bridge](#!/model/model.uspto_dbt.fct_assignment_bridge): The link between companies and patents.

{% enddocs %}
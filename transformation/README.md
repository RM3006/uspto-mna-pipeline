# Transformation (dbt)

This directory contains the **dbt (data build tool)** project responsible for transforming raw XML data into the final analytical star schema.

## Project Structure

### Models (`/models`)
* **Staging (`/staging`):**
    * Materialized as tables.
    * Cleans and extracts data from the raw `VARIANT` XML column.
    * Flattening logic converts nested XML arrays into relational rows.
    * Includes: `stg_patent_assignees`, `stg_patent_assignments`, `stg_patent_properties`.
* **Marts (`/marts`):**
    * Implements a Star Schema architecture.
    * **Dimensions:** `dim_patents`, `dim_assignees`, `dim_assignments`.
    * **Facts:** `fct_assignment_bridge` (Links the dimensions).
    * Includes surrogate key generation (MD5) and deduplication logic.
* **Reporting (`/marts`):**
    * `rpt_data_science_input`: A denormalized One Big Table (OBT) view optimized for data science and visualization consumption.

### Macros (`/macros`)
Reusable Jinja functions to enforce DRY (Don't Repeat Yourself) principles:
* `get_xml_value.sql`: robustly extracts text from XML nodes.
* `clean_assignee_name.sql`: standardizes company names.
* `generate_schema_name.sql`: manages environment-specific schema routing (Dev vs. Prod).

### Tests (`/tests`)
* **Generic Tests:** Configuration in `schema.yaml` ensures `unique` and `not_null` constraints on primary keys.
* **Singular Tests:** Custom SQL assertions (e.g., `assert_assignee_name_is_present`) to validate specific business logic and data quality rules.

### Documentation
Documentation is defined in `schema.yaml` and `common_columns.md` using doc blocks. This allows for the automatic generation of a static documentation site via `dbt docs generate`.
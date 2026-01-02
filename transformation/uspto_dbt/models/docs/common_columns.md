{% docs common_xml_source %}
The raw, semi-structured XML string extracted directly from the source file. Retained for auditing and debugging parsing logic.
{% enddocs %}

{% docs common_filename %}
The name of the source ZIP or XML file from which this record was extracted.
{% enddocs %}

{% docs audit_loaded_at %}
Timestamp indicating exactly when this record was processed and inserted into the warehouse.
{% enddocs %}

{% docs common_reel_no %}
The 'Reel Number' identifier for the assignment record. Used in combination with Frame Number to uniquely identify an assignment transaction.
{% enddocs %}

{% docs common_frame_no %}
The 'Frame Number' identifier for the assignment record. Used in combination with Reel Number to uniquely identify an assignment transaction.
{% enddocs %}

{% docs common_assignee_name %}
The normalized name of the company or entity receiving the patent assignment.
{% enddocs %}

{% docs common_assignee_sk %}
Surrogate Key (MD5 hash) generated from the cleaned assignee name. Used to join Fact tables to the Assignee Dimension.
{% enddocs %}

{% docs common_city %}
The city name associated with the entity, as extracted from the raw XML.
{% enddocs %}

{% docs common_state %}
The state or province code (e.g., 'CA', 'NY'). Often NULL for non-US entities.
{% enddocs %}

{% docs common_country %}
The two-letter ISO country code (e.g., 'US', 'JP') associated with the entity or patent document.
{% enddocs %}

{% docs common_patent_number %}
The unique document number assigned to the patent (e.g., '10923456').
{% enddocs %}

{% docs common_patent_sk %}
Surrogate Key (MD5 hash) generated from the patent document number. Used to join Fact tables to the Patent Dimension.
{% enddocs %}

{% docs common_kind_code %}
The WIPO Standard ST.16 kind code indicating the document type (e.g., 'B2' for a granted patent).
{% enddocs %}

{% docs common_invention_title %}
The official title of the invention as registered with the USPTO.
{% enddocs %}

{% docs common_doc_date %}
The date the patent document was published or granted (YYYY-MM-DD).
{% enddocs %}

{% docs common_conveyance_text %}
A description of the legal transfer of rights (e.g., 'ASSIGNMENT OF ASSIGNORS INTEREST').
{% enddocs %}

{% docs common_page_count %}
The number of pages included in the official assignment record.
{% enddocs %}

{% docs common_record_date %}
The date the assignment was officially recorded at the USPTO.
{% enddocs %}

{% docs common_last_update_date %}
The date the record was last updated in the source system.
{% enddocs %}

{% docs common_assignment_sk %}
Surrogate Key (MD5 hash) generated from the Reel and Frame numbers. Used to identify a unique transaction.
{% enddocs %}

{% docs common_days_since_pub %}
Calculated field: The number of days elapsed between the patent's document date (grant/publication) and the assignment recording date. Used to analyze the "age" of a patent at the time of transaction.
{% enddocs %}
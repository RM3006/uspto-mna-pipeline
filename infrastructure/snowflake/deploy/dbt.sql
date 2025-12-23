with source as (
SELECT 
*
FROM
{{source , 'uspto', 'patent_assignment_xml'}}
),

parsed as (
    SELECT
    file_name,
    loaded_at,
    xmlget(xml_content, 'assignment-record') as record_node,
    xmlget(record_node,'reel-no'):"$" :: VARCHAR as reel_number,
    xmlget(record_node,'frame-no'):"$" :: VARCHAR as frame_number,
    xmlget(record_node,'conveyance-text'):"$" :: VARCHAR as conveyance_text,
    TRY_TO_DATE(xmlget(xmlget(record_node,'last-update-date'),'date'):"$"      R as conveyance_text,
    xmlget(record_node,'conveyance-text'):"$" :: VARCHAR as conveyance_text,
)
/*
    Questions never viewed in the last 3 months

    https://discourse.metabase.com/t/metabase-metadata-sql/3688/14
*/
SELECT
    rc.id,
    CONCAT('https://domain.metabase.net/question/', rc.id) AS CardUrl,
    rc.name AS CardName,
    rc.description AS CardDescription
FROM report_card AS rc
WHERE rc.id NOT IN (
    SELECT vl.model_id
    FROM view_log AS vl
    WHERE 1=1
        AND vl.model='card'
        -- last 3 months
        AND STR_TO_DATE(CONCAT(DATE_FORMAT(vl.timestamp, '%Y-%m'), '-01'), '%Y-%m-%d')
            BETWEEN STR_TO_DATE(CONCAT(DATE_FORMAT(DATE_ADD(NOW(6), INTERVAL -3 MONTH), '%Y-%m'), '-01'), '%Y-%m-%d')
                AND STR_TO_DATE(CONCAT(DATE_FORMAT(NOW(6), '%Y-%m'), '-01'), '%Y-%m-%d')
)
;

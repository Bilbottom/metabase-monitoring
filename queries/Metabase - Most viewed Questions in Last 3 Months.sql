/*
    Most viewed questions in the last 3 months

    https://discourse.metabase.com/t/metabase-metadata-sql/3688/14
*/
SELECT
    rc.name AS question_name,
    COUNT(cu.id) AS view_count,
    COUNT(DISTINCT vl.user_id) AS distinct_users,
    CONCAT('https://domain.metabase.net/question/', vl.model_id) AS question_link
FROM core_user AS cu
    INNER JOIN view_log AS vl
        ON vl.user_id = cu.id
    INNER JOIN report_card AS rc
        ON rc.id = vl.model_id
WHERE 1=1
    AND vl.model = 'card'
    AND CAST(timestamp AS DATE) >= DATE_ADD(CURRENT_DATE(), INTERVAL -3 MONTH)
GROUP BY
    vl.model_id,
    rc.name
ORDER BY
    view_count DESC
;

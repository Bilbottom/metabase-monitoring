/*
    Most viewed dashboards in the last 3 months

    https://discourse.metabase.com/t/metabase-metadata-sql/3688/13
*/
SELECT
    rd.name AS dashboard_name,
    COUNT(cu.id) AS view_count,
    COUNT(DISTINCT vl.user_id) AS distinct_users,
    CONCAT('https://domain.metabase.net/dashboard/', vl.model_id) AS dashboard_link
FROM core_user AS cu
    INNER JOIN view_log AS vl
        ON vl.user_id = cu.id
    INNER JOIN report_dashboard AS rd
        ON rd.id = vl.model_id
WHERE 1=1
    AND vl.model = 'dashboard'
    AND CAST(timestamp AS DATE) >= DATE_ADD(CURRENT_DATE(), INTERVAL -3 MONTH)
GROUP BY
    vl.model_id,
    rd.name
ORDER BY
    view_count DESC
;

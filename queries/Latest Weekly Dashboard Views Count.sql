/* SQL Server */

WITH RECURSIVE
    axis AS (
            SELECT CAST('2021-05-23' AS DATE) AS date_at
        UNION ALL
            SELECT DATE_ADD(date_at, INTERVAL 7 DAY) AS date_at
            FROM axis
            WHERE date_at < CURRENT_DATE()
    ),
    base AS (
        SELECT
            DATE_SUB(CAST(timestamp AS DATE), INTERVAL DAYOFWEEK(timestamp) - 1 DAY) AS week_commencing,
            COUNT(*) AS dashboard_views
        FROM view_log
        WHERE model = 'dashboard'
        GROUP BY 1
    )

SELECT
    axis.date_at,
    COALESCE(base.dashboard_views, 0) AS "Total Dashboard Views"
FROM axis
    LEFT JOIN base ON axis.date_at = base.week_commencing
WHERE axis.date_at < DATE_SUB(CAST(CURRENT_DATE() AS DATE), INTERVAL DAYOFWEEK(CURRENT_DATE()) - 1 DAY)
ORDER BY axis.date_at
;

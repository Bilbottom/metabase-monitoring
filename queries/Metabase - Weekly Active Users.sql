/*
    Weekly active users

    https://discourse.metabase.com/t/metabase-metadata-sql/3688/10
*/
WITH RECURSIVE
    axis AS (
            SELECT CAST('2021-05-23' AS DATE) AS date_at
        UNION ALL
            SELECT DATE_ADD(date_at, INTERVAL 7 DAY) AS date_at
            FROM axis
            WHERE date_at < DATE_ADD(CURRENT_DATE(), INTERVAL -7 DAY)
    ),
    base AS (
        SELECT
            DATE_SUB(CAST(created_at AS DATE), INTERVAL DAYOFWEEK(created_at) - 1 DAY) AS week_commencing,
            COUNT(DISTINCT user_id) AS active_users
        FROM core_session
        GROUP BY 1
    )

SELECT
    axis.date_at,
    COALESCE(base.active_users, 0) AS "Active Users"
FROM axis
    LEFT JOIN base ON axis.date_at = base.week_commencing
ORDER BY axis.date_at
;

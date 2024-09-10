/*
    Timeseries of cumulated new users (SQL Server)

    https://discourse.metabase.com/t/metabase-metadata-sql/3688/10
*/
WITH RECURSIVE
    axis AS (
            SELECT CAST('2021-05-24' AS DATE) AS date_at
        UNION ALL
            SELECT DATE_ADD(date_at, INTERVAL 1 DAY) AS date_at
            FROM axis
            WHERE date_at < CURRENT_DATE()
    ),
    base AS (
        SELECT
            CAST(timestamp AS DATE) AS date_at,
            COUNT(user_id) AS user_joined
        FROM activity
        WHERE topic = 'user-joined'
        GROUP BY date_at
    )

SELECT
    axis.date_at,
    COALESCE(base.user_joined, 0) AS "New Users",
    SUM(base.user_joined) OVER(
        ORDER BY axis.date_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS "Running Users"
FROM axis
    LEFT JOIN base ON axis.date_at = base.date_at
ORDER BY axis.date_at
;

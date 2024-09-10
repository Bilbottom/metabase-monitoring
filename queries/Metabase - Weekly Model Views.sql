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
            DATE_SUB(CAST(view_log.timestamp AS DATE), INTERVAL DAYOFWEEK(view_log.timestamp) - 1 DAY) AS week_commencing,
            view_log.model,
            COUNT(*) AS total_views
        FROM view_log
            INNER JOIN core_user
                ON view_log.user_id = core_user.id
            LEFT JOIN report_dashboard
                ON  view_log.model_id = report_dashboard.id
                AND view_log.model = 'dashboard'
            LEFT JOIN report_card
                ON  view_log.model_id = report_card.id
                AND view_log.model = 'card'
        WHERE 1=1
            [[AND {{first_name}}]]
            [[AND {{last_name}}]]
            [[AND {{user_id}}]]
            /* for the Field Filter */
            [[AND {{model}}]]
            [[AND {{dashboard_name}}]]
            [[AND {{question_name}}]]
            /* for the Text filter */
            [[AND COALESCE(report_dashboard.name, report_card.name) = {{model_name}}]]
        GROUP BY 1,2
    )

SELECT
    DATE_FORMAT(axis.date_at, '%Y-%m-%d') AS week_commencing,
    COALESCE(d.total_views, 0) AS "Dashboard Views",
    COALESCE(q.total_views, 0) AS "Question Views"
FROM axis
    LEFT JOIN base AS d
        ON  axis.date_at = d.week_commencing
        AND d.model = 'dashboard'
    LEFT JOIN base AS q
        ON  axis.date_at = q.week_commencing
        AND q.model = 'card'
ORDER BY axis.date_at
;

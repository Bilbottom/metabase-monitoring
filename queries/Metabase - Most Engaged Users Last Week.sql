WITH base AS (
    SELECT
        DATE_SUB(CAST(timestamp AS DATE), INTERVAL DAYOFWEEK(timestamp) - 1 DAY) AS week_commencing,
        user_id,
        model,
        COUNT(*) AS total_views,
        COUNT(DISTINCT model_id) AS distinct_views
    FROM view_log
    WHERE DATE_SUB(CAST(timestamp AS DATE), INTERVAL DAYOFWEEK(timestamp) - 1 DAY) = DATE_ADD(DATE_SUB(CAST(CURRENT_DATE() AS DATE), INTERVAL DAYOFWEEK(CURRENT_DATE()) - 1 DAY), INTERVAL -7 DAY)
    GROUP BY
        week_commencing,
        user_id,
        model
)

SELECT
    DATE_FORMAT (user_ids.week_commencing, '%Y-%m-%d') AS "Week Commencing",
    user_ids.user_id aS "User ID",
    CONCAT(core_user.first_name, ' ', core_user.last_name) AS "User Name",
    COALESCE(base_q.total_views, 0) AS "Total Question Views",
    COALESCE(base_d.total_views, 0) AS "Total Dashboard Views",
    COALESCE(base_q.distinct_views, 0) AS "Distinct Questions Viewed",
    COALESCE(base_d.distinct_views, 0) AS "Distinct Dashboards Viewed"
FROM (
    SELECT DISTINCT week_commencing, user_id FROM base
) AS user_ids
    LEFT JOIN base AS base_q
        ON  user_ids.week_commencing = base_q.week_commencing
        AND user_ids.user_id = base_q.user_id
        AND base_q.model = 'card'
    LEFT JOIN base AS base_d
        ON  user_ids.week_commencing = base_d.week_commencing
        AND user_ids.user_id = base_d.user_id
        AND base_d.model = 'dashboard'
    LEFT JOIN core_user
        ON user_ids.user_id = core_user.id
WHERE 1=1
    [[AND {{first_name}}]]
    [[AND {{last_name}}]]
ORDER BY (COALESCE(base_q.total_views, 0) + COALESCE(base_d.total_views, 0)) DESC
-- LIMIT 10
;

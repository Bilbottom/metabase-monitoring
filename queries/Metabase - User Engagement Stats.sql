WITH base AS (
    SELECT
        core_user.id AS user_id,
        CONCAT(core_user.first_name, ' ', core_user.last_name) AS user_name,
        view_log.model,
        COUNT(*) AS total_views,
        COUNT(DISTINCT view_log.model_id) AS distinct_views
    FROM core_user
        LEFT JOIN view_log
            ON core_user.id = view_log.user_id
    WHERE 1=1
        [[AND {{first_name}}]]
        [[AND {{last_name}}]]
        [[AND {{user_id}}]]
    GROUP BY core_user.id, view_log.model
)

SELECT
    user_ids.user_id AS "User ID",
    user_ids.user_name AS "User Name",
    COALESCE(base_q.total_views, 0) AS "Total Question Views",
    COALESCE(base_d.total_views, 0) AS "Total Dashboard Views",
    COALESCE(base_q.distinct_views, 0) AS "Distinct Questions Viewed",
    COALESCE(base_d.distinct_views, 0) AS "Distinct Dashboards Viewed"
FROM (
    SELECT DISTINCT user_id, user_name FROM base
) AS user_ids
    LEFT JOIN base AS base_q
        ON  user_ids.user_id = base_q.user_id
        AND base_q.model = 'card'
    LEFT JOIN base AS base_d
        ON  user_ids.user_id = base_d.user_id
        AND base_d.model = 'dashboard'
ORDER BY (COALESCE(base_q.total_views, 0) + COALESCE(base_d.total_views, 0)) DESC
-- LIMIT 10
;

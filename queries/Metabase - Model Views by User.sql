/*
    Which dashboards has a user viewed

    https://discourse.metabase.com/t/metabase-metadata-sql/3688
*/
WITH base AS (
    SELECT
        COALESCE(report_dashboard.name, report_card.name) AS model_name,
        view_log.model,
        core_user.id AS user_id,
        CONCAT(core_user.first_name, ' ', core_user.last_name) AS user_name,
        COUNT(core_user.id) AS view_count,
        MIN(view_log.timestamp) AS first_viewed,
        MAX(view_log.timestamp) AS last_viewed
    FROM core_user
        INNER JOIN view_log
            ON view_log.user_id = core_user.id
        LEFT JOIN report_dashboard
            ON  report_dashboard.id = view_log.model_id
            AND view_log.model = 'dashboard'
        LEFT JOIN report_card
            ON  report_card.id = view_log.model_id
            AND view_log.model = 'card'
    WHERE 1=1
        [[AND {{model}}]]
        [[AND {{first_name}}]]
        [[AND {{last_name}}]]
        [[AND {{user_id}}]]
    GROUP BY
        user_id,
        model,
        model_name
    ORDER BY
        user_id,
        model_name
)

SELECT *
FROM base
WHERE 1=1
    [[AND model_name = {{model_name}}]]
    -- [AND model_name LIKE CONCAT('%', {model_name}, '%')]
;

/*
    Which dashboards has a user viewed

    https://discourse.metabase.com/t/metabase-metadata-sql/3688
*/
SELECT
    view_log.model_id AS dashboard_id,
    report_dashboard.name AS dashboard_name,
    core_user.id AS user_id,
    CONCAT(core_user.first_name, ' ', core_user.last_name) AS user_name,
    COUNT(*) AS view_count,
    MIN(view_log.timestamp) AS first_viewed,
    MAX(view_log.timestamp) AS last_viewed
FROM view_log
    LEFT JOIN core_user
        ON view_log.user_id = core_user.id
    LEFT JOIN report_dashboard
        ON report_dashboard.id = view_log.model_id
WHERE 1=1
    AND view_log.model = 'dashboard'
    [[AND {{first_name}}]]
    [[AND {{last_name}}]]
    [[AND {{dashboard_name}}]]
    [[AND {{dashboard_id}}]]
    AND view_log.model_id IN (
        SELECT report_dashboard.id
        FROM report_dashboard
            LEFT JOIN report_dashboardcard
                ON report_dashboard.id = report_dashboardcard.dashboard_id
            LEFT JOIN report_card
                ON report_dashboardcard.card_id = report_card.id
        WHERE 1=1
            [[AND {{question_name}}]]
            [[AND {{question_id}}]]
    )
GROUP BY
    view_log.model_id,
    report_dashboard.name,
    core_user.id
ORDER BY
    view_log.model_id,
    last_viewed DESC
;

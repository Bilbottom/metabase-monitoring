/*
    Which questions has a user viewed
*/
SELECT
    view_log.model_id AS question_id,
    report_card.name AS question_name,
    core_user.id AS user_id,
    CONCAT(core_user.first_name, ' ', core_user.last_name) AS user_name,
    COUNT(*) AS view_count,
    MIN(view_log.timestamp) AS first_viewed,
    MAX(view_log.timestamp) AS last_viewed
FROM view_log
    LEFT JOIN core_user
        ON view_log.user_id = core_user.id
    LEFT JOIN report_card
        ON view_log.model_id = report_card.id
WHERE 1=1
    AND view_log.model = 'card'
    [[AND {{first_name}}]]
    [[AND {{last_name}}]]
    [[AND {{question_name}}]]
    [[AND {{question_id}}]]
    AND view_log.model_id IN (
        SELECT report_card.id
        FROM report_card
            LEFT JOIN report_dashboardcard
                ON report_card.id = report_dashboardcard.card_id
            LEFT JOIN report_dashboard
                ON report_dashboardcard.dashboard_id = report_dashboard.id
        WHERE 1=1
            [[AND {{dashboard_name}}]]
            [[AND {{dashboard_id}}]]
    )
GROUP BY
    view_log.model_id,
    report_card.name,
    core_user.id
ORDER BY
    view_log.model_id,
    last_viewed DESC
;

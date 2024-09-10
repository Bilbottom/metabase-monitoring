SELECT
    view_log.id,
    view_log.user_id,
    view_log.model_id AS dashboard_id,
    view_log.timestamp,
    CONCAT(core_user.first_name, ' ', core_user.last_name) AS user_name
FROM view_log
    LEFT JOIN core_user
        ON view_log.user_id = core_user.id
WHERE 1=1
    AND view_log.model = 'dashboard'
    AND view_log.model_id NOT IN (
        SELECT id FROM report_dashboard
    )
;

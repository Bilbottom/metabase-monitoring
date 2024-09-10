WITH models AS (
        SELECT
            'card' AS model,
            id,
            name,
            creator_id,
            collection_id
        FROM report_card
    UNION ALL
        SELECT
            'dashboard' AS model,
            id,
            name,
            creator_id,
            collection_id
        FROM report_dashboard
)

SELECT
    models.model,
    models.name AS model_name,
    collection.name AS collection_name,
    models.creator_id AS owner_id,
    CONCAT(core_user.first_name, ' ', core_user.last_name) AS owner_name,
    CONCAT('https://domain.metabase.net/question/', models.id) AS model_hyperlink,
    view_log.view_count,
    view_log.distinct_viewers,
    view_log.first_viewed,
    view_log.last_viewed
FROM models
    LEFT JOIN core_user
        ON models.creator_id = core_user.id
    LEFT JOIN collection
        ON models.collection_id = collection.id
    LEFT JOIN (
        SELECT
            model,
            model_id,
            COUNT(*) AS view_count,
            COUNT(DISTINCT user_id) AS distinct_viewers,
            MIN(timestamp) AS first_viewed,
            MAX(timestamp) AS last_viewed
        FROM view_log
        GROUP BY model, model_id
    ) AS view_log
        ON  models.model = view_log.model
        AND models.id = view_log.model_id
WHERE 1=1
    [[AND models.model = {{model}}]]
    [[AND {{first_name}}]]
    [[AND {{last_name}}]]
    [[AND {{user_id}}]]
ORDER BY
    models.id,
    models.model
;

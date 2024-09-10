WITH
    base AS (
        SELECT
            id,
            name,
            archived,
            IF(name LIKE '%Personal Collection%', True, False) AS personal_collection_flag,
            LEFT(
                SUBSTRING(location, 2),
                LOCATE('/', SUBSTRING(location, 2)) - 1
            ) AS root_id
        FROM collection
    ),
    pers_coll AS (
        SELECT
            b1.id,
            b1.name,
            b1.archived,
            b1.personal_collection_flag,
            b1.root_id,
            b2.name AS root_name,
            b2.personal_collection_flag AS root_personal_collection_flag,
            COALESCE(b2.personal_collection_flag, b1.personal_collection_flag) AS is_personal_collection_flag
        FROM base AS b1
            LEFT JOIN base AS b2
                ON b1.root_id = b2.id
    )

SELECT
    report_card.id AS question_id,
    report_card.name AS question_name,
    collection.name AS collection_name,
    report_card.creator_id AS owner_id,
    CONCAT(core_user.first_name, ' ', core_user.last_name) AS owner_name,
    COALESCE(view_log.view_count, 0) AS view_count,
    COALESCE(view_log.distinct_viewers, 0) AS distinct_viewers,
    view_log.first_viewed,
    view_log.last_viewed,
    CONCAT('https://domain.metabase.net/question/', report_card.id) AS question_hyperlink,
    CONCAT('https://domain.metabase.net/collection/', report_card.collection_id) AS collection_hyperlink
FROM report_card
    LEFT JOIN core_user
        ON report_card.creator_id = core_user.id
    LEFT JOIN collection
        ON report_card.collection_id = collection.id
    LEFT JOIN (
        SELECT
            model_id,
            COUNT(*) AS view_count,
            COUNT(DISTINCT user_id) AS distinct_viewers,
            MIN(timestamp) AS first_viewed,
            MAX(timestamp) AS last_viewed
        FROM view_log
        WHERE 1=1
            AND model = 'card'
            AND CAST(timestamp AS DATE) >= DATE_ADD(CURRENT_DATE(), INTERVAL -3 MONTH)
        GROUP BY model_id
    ) AS view_log
        ON report_card.id = view_log.model_id
WHERE 1=1
    AND report_card.archived = 0
    AND collection.id NOT IN (SELECT id FROM pers_coll WHERE is_personal_collection_flag)
    [[AND {{first_name}}]]
    [[AND {{last_name}}]]
    [[AND {{user_id}}]]
    [[AND {{question_name}}]]
    [[AND {{question_id}}]]
    [[AND COALESCE(view_log.view_count, 0) <= {{view_limit}}]]
ORDER BY COALESCE(view_log.view_count, 0), report_card.id
;

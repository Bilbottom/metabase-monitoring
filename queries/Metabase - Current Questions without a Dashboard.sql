/*
    Questions without a dashboard

    https://discourse.metabase.com/t/metabase-metadata-sql/3688
*/
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
    q.id,
    q.name,
    -- q.display,
    q.query_type,
    -- CONCAT(cu.first_name, ' ', cu.last_name) AS owner,
    c.name AS collection,
    CONCAT('https://domain.metabase.net/question/', q.id) AS hyperlink
FROM report_card AS q
    LEFT JOIN report_dashboardcard AS rdc
        ON rdc.card_id = q.id
    -- LEFT JOIN core_user AS cu
    --     ON q.creator_id = cu.id
    LEFT JOIN collection AS c
        ON q.collection_id = c.id
WHERE 1=1
    AND q.archived = 0
    AND rdc.card_id IS NULL
    AND c.id NOT IN (SELECT id FROM pers_coll WHERE is_personal_collection_flag)
    [[AND {{question_name}}]]
    [[AND {{question_id}}]]
;

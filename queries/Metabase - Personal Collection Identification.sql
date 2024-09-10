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

SELECT *
FROM pers_coll
;

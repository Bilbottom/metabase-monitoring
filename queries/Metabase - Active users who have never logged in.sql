/*
    Users who have never logged in

    https://discourse.metabase.com/t/metabase-metadata-sql/3688
*/
SELECT
    id AS "User ID",
    email AS "Email",
    first_name AS "First Name",
    last_name AS "Last Name"
FROM core_user
WHERE 1=1
    AND last_login IS NULL
    AND is_active = True
;

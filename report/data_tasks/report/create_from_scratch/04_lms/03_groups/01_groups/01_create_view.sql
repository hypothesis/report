DROP MATERIALIZED VIEW IF EXISTS lms.groups CASCADE;

CREATE MATERIALIZED VIEW lms.groups AS (
    SELECT
        CONCAT('us-', id) AS id,
        'us' AS region,
        CASE
            WHEN parent_id IS NULL THEN NULL
            ELSE CONCAT('us-', parent_id)
        END AS parent_id,
        authority_provided_id, name, group_type, created,
        -- From bubbled counts
        teacher_count, user_count, assignment_count, document_count
    FROM lms_us.groups
    JOIN lms_us.group_bubbled_counts ON
        group_bubbled_counts.group_id = groups.id

    UNION ALL

    SELECT
        CONCAT('ca-', id) AS id,
        'ca' AS region,
        CASE
            WHEN parent_id IS NULL THEN NULL
            ELSE CONCAT('ca-', parent_id)
        END AS parent_id,
        authority_provided_id, name, group_type, created,
        -- From bubbled counts
        teacher_count, user_count, assignment_count, document_count
    FROM lms_ca.groups
    JOIN lms_ca.group_bubbled_counts ON
        group_bubbled_counts.group_id = groups.id
) WITH NO DATA;

DROP MATERIALIZED VIEW IF EXISTS lms.organizations CASCADE;

CREATE MATERIALIZED VIEW lms.organizations AS (
    WITH
        raw_organizations AS (
            SELECT
                CONCAT('us-', id) AS id,
                CONCAT('us.lms.org.', public_id) AS public_id,
                name,
                'us' AS region,
                created,
                updated,
                enabled
            FROM lms_us.organization

            UNION ALL

            SELECT
                CONCAT('ca-', id) AS id,
                CONCAT('ca.lms.org.', public_id) AS public_id,
                name,
                'ca' AS region,
                created,
                updated,
                enabled
            FROM lms_ca.organization
        ),

        hubspot_names AS (
            SELECT
                lms_organization_id,
                STRING_AGG(DISTINCT(name), ' / ') as hubspot_name
            FROM hubspot.companies
            WHERE lms_organization_id IS NOT NULL
            GROUP BY lms_organization_id
        )

    SELECT
        raw_organizations.*,
        hubspot_names.hubspot_name
    FROM raw_organizations
    LEFT OUTER JOIN hubspot_names ON
        raw_organizations.public_id = hubspot_names.lms_organization_id
) WITH NO DATA;

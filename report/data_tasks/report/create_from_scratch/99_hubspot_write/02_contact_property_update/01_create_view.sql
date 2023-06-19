DROP VIEW IF EXISTS hubspot.contact_property_update CASCADE;

-- This view recreates the properties that we update on Hubspot contacts
CREATE VIEW hubspot.contact_property_update AS (
    WITH contact_users AS (
        SELECT
            contacts.id AS hs_object_id,
            -- This is a little confusing, but the id here comes from H
            -- originally, but is just processed through the LMS reporting system
            MAX(users.id) AS h_user_id
        FROM hubspot.contacts
        -- We are going to assume people never _stop_ being a teacher. This means
        -- we will never remove the `Teacher` status from a contact. The upside is
        -- we will update far fewer records, which should happen quicker.
        JOIN lms.users ON
            -- Emails in the contacts table are already stored as lower case
            contacts.email = LOWER(users.email)
            -- We definitely want to NOT join onto student information to keep that
            -- out of Hubspot
            AND users.is_teacher = True
        GROUP BY contacts.id
    )

    SELECT
        contact_users.hs_object_id,
        contact_users.h_user_id,
        'Teacher' AS lms_role
    FROM contact_users
);

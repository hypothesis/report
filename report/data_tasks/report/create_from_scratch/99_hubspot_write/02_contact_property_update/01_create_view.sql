DROP VIEW IF EXISTS hubspot.contact_property_update CASCADE;

-- This view recreates the properties that we update on Hubspot contacts
CREATE VIEW hubspot.contact_property_update AS (
    SELECT
        contacts.id AS hs_object_id,
        'Teacher' AS lms_role
    FROM hubspot.contacts
    -- We are going to assume people never _stop_ being a teacher. This means
    -- we will never remove the `Teacher` status from a contact. The upside is
    -- we will update far fewer records, which should happen quicker.
    JOIN lms.users ON
        contacts.email = users.email
        -- We definitely want to NOT join onto student information to keep that
        -- out of Hubspot
        AND users.is_teacher = True
    GROUP BY contacts.id
);

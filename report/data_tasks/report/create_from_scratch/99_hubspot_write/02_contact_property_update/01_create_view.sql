DROP VIEW IF EXISTS hubspot.contact_property_update CASCADE;

-- This view recreates the properties that we update on Hubspot contacts
CREATE VIEW hubspot.contact_property_update AS (
    WITH contact_users AS (
        SELECT
            contacts.id AS hs_object_id,
            -- This is a little confusing, as the id here comes from H,
            -- but is just processed through the LMS reporting system
            MAX(users.id) AS h_user_id,
            MAX(users.last_active_date) AS lms_last_active
        FROM hubspot.contacts
        -- We are going to assume people never _stop_ being a teacher. This
        -- means we will never remove the `Teacher` status from a contact. The
        -- upside is we will update far fewer records, which should happen
        -- quicker.
        JOIN lms.users ON
            -- Emails in the contacts table are already stored as lower case
            contacts.email = LOWER(users.email)
            -- We definitely want to NOT join onto student information to keep
            -- that out of Hubspot
            AND users.is_teacher = True
        GROUP BY contacts.id
    )

    SELECT
        contact_users.hs_object_id,
        contact_users.h_user_id,
        'Teacher' AS lms_role,
        contact_users.lms_last_active,
        COALESCE(course_activity.lms_annotations_this_semester, 0) AS lms_annotations_this_semester,
        CURRENT_DATE AS reporting_last_update
    FROM contact_users

    LEFT OUTER JOIN (
        SELECT
            user_id,
            SUM(annotation_count) AS lms_annotations_this_semester
        FROM lms.users
        JOIN lms.group_roles ON
            group_roles.user_id = users.id
            AND group_roles.role = 'teacher'
        JOIN lms.group_bubbled_activity ON
            group_bubbled_activity.group_id = group_roles.group_id
            AND group_bubbled_activity.created_week >= report.multi_truncate('semester', CURRENT_DATE)
        JOIN lms.groups ON
            -- We are limiting by courses, because we want to count courses. We
            -- still get the right counts for non-unique items by using the
            -- bubbled version of the table
            groups.id = group_roles.group_id
            AND groups.group_type = 'course'
        GROUP BY user_id
    ) AS course_activity ON
        course_activity.user_id = contact_users.h_user_id
);

-- A full flattened view of the activity counts where each type of count
-- for teachers and users is in a separate column. This allows for easier
-- comparison of metrics in the same graph / table etc.
CREATE VIEW organization_activity_flat AS (
    SELECT
        user_activity.timescale,
        user_activity.timestamp,
        user_activity.period,
        user_activity.organization_id,

        user_activity.annotation_count AS user_annotation_count,
        user_activity.annotation_count_growth AS user_annotation_count_growth,
        user_activity.active AS active_users,
        user_activity.active_growth AS active_user_growth,
        user_activity.billable AS billable_users,
        user_activity.billable_growth AS billable_user_growth,

        teacher_activity.annotation_count AS teacher_annotation_count,
        teacher_activity.annotation_count_growth AS teacher_annotation_count_growth,
        teacher_activity.active AS active_teachers,
        teacher_activity.active_growth AS active_teacher_growth,
        teacher_activity.billable AS billable_teachers,
        teacher_activity.billable_growth AS billable_teacher_growth
    FROM organization_activity AS user_activity
    JOIN organization_activity AS teacher_activity ON
        teacher_activity.timescale = user_activity.timescale
        AND teacher_activity.period = user_activity.period
        AND teacher_activity.organization_id = user_activity.organization_id
        AND teacher_activity.role = 'teacher'
    WHERE
        user_activity.role = 'user'
);
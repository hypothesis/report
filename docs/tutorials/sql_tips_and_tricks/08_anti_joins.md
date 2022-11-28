# Anti-joins

It's common to want to join something to ensure they match. Let's say we want
to find all application instances which have `group_info` records with a blank
GUID:

```sql
SELECT
    DISTINCT(application_instances.id)
FROM application_instances
JOIN group_info
    ON group_info.application_instance_id = application_instances.id
    AND group_info.tool_consumer_instance_guid IS NULL
```

But what if you want to select something to ensure they don't join?

For example, lets say we want to select all application instances which 
**_don't_** have a `group_info` entry with a blank value. There are doubtless
a million ways, but one way is an anti-join. 

This isn't something built in so much as a technique using regular joins.

## It's just a fancy outer join

```sql
SELECT
    application_instances.id
FROM application_instances
LEFT OUTER JOIN group_info
    ON group_info.application_instance_id = application_instances.id
    AND group_info.tool_consumer_instance_guid IS NULL
WHERE
    group_info.id IS NULL
```

This is a bit weird, but what we do is:

 * Join on the condition we don't want to happen
 * Make it an `OUTER` join, so if the condition fails we get NULLs
 * Check a field which can't be null with a match is NULL
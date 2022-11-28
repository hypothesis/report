# Unions

## Remembing they exist

When working with our old and dodgy GUIDs you can get some of the data from
the `application_instances`:

```sql
SELECT 
    id as application_instance_id, 
    tool_consumer_instance_guid as guid
FROM application_instances
WHERE tool_consumer_instance_guid = 'localhost'
```

But if you want the full picture you also need to consult `group_info`:

```sql
SELECT 
    application_instance_id, 
    tool_consumer_instance_guid as guid
FROM group_info
WHERE tool_consumer_instance_guid = 'localhost'
```

In order to get all of these together in one query you can use a `UNION`

```sql
SELECT 
    id as application_instance_id, 
    tool_consumer_instance_guid as guid
FROM application_instances
WHERE tool_consumer_instance_guid = 'localhost'

UNION

SELECT 
    application_instance_id, tool_consumer_instance_guid 
FROM group_info
WHERE tool_consumer_instance_guid = 'localhost'
```

Notice the columns aren't aliased in the second one. Postgres doesn't care what
the columns are as long as they can be coerced into the same types.

## There's more than one type! `UNION ALL` 

You probably want `UNION` in most cases, which removes duplicate values, but
if you don't you can use `UNION ALL` which will keep them.
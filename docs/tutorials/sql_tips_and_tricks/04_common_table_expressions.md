# Common Table Expressions (CTEs) for tidier queries

## The motivation

In the previous examples we showed some unioned queries like this:

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

This works, but we might want to apply our sub-query skills to do this without
repeating the where clause:

```sql
SELECT * FROM (
    SELECT 
        id as application_instance_id, 
        tool_consumer_instance_guid as guid
    FROM application_instances
    
    UNION
    
    SELECT 
        application_instance_id, tool_consumer_instance_guid 
    FROM group_info

) AS all_guids
WHERE guid = 'localhost'
```

This is particularly useful if the condition we want is complicated:

```sql
SELECT * FROM (
    SELECT 
        id as application_instance_id, 
        tool_consumer_instance_guid as guid
    FROM application_instances
    
    UNION
    
    SELECT 
        application_instance_id, tool_consumer_instance_guid 
    FROM group_info

) AS all_guids
WHERE 
    guid IN ('localhost', '12398755', 'canvas')
    OR guid IS NULL
ORDER BY
    application_instance_id DESC
```

But this can start to get quite hard to read. 

## Common Table Expressions (CTEs) to the rescue

CTEs allow us to define a sub-query, give it a name and then re-use it:

```sql
WITH
    all_guids AS (
        SELECT 
            id as application_instance_id, 
            tool_consumer_instance_guid as guid
        FROM application_instances
        
        UNION
        
        SELECT 
            application_instance_id, tool_consumer_instance_guid 
        FROM group_info
    )
    
SELECT * 
FROM all_guids
WHERE 
    guid IN ('localhost', '12398755', 'canvas')
    OR guid IS NULL
ORDER BY
    application_instance_id DESC
```

This gets really helpful if you are joining multiple things, and is a nice way
to keep a query in Metabase (for example) tidy and comprehendable. 

If you have more than one, you only use `WITH` once:

```sql
WITH
    item_1 AS (SELECT ...),
    item_2 AS (SELECT ...)
```



# Selecting fixed values

It can be handy to have some canned data in your query. 


```sql
SELECT 
    column1 AS consumer_key,  
    column2 AS tool_consumer_instance_guid
FROM (
    VALUES 
    ('Hypothesis079e529cee16ecc6b30ceda7b2efc3a0', 'My custom value 1'),
    ('Hypothesis57984238af9c8ead9a5d0182e449b19b', 'My custom value 2')
) AS data
```

Note the aliases here to get nicer column names.

For example you could join on to this to provide overrides for certain fields:

```sql
SELECT 
    application_instances.consumer_key, 
    application_instances.tool_consumer_instance_guid,
    canned_values.tool_consumer_instance_guid
FROM 
    application_instances
LEFT OUTER JOIN (
    SELECT 
        column1 AS consumer_key,  
        column2 AS tool_consumer_instance_guid
    FROM (
        VALUES 
        ('Hypothesis079e529cee16ecc6b30ceda7b2efc3a0', 'My custom value 1'),
        ('Hypothesis57984238af9c8ead9a5d0182e449b19b', 'My custom value 2')
    ) AS data
) AS canned_values
ON
    application_instances.consumer_key = canned_values.consumer_key
```

This is particularly good with CTEs as well:

```sql
WITH
    canned_values AS (
        SELECT 
        column1 AS consumer_key,  
        column2 AS tool_consumer_instance_guid
    FROM (
        VALUES 
        ('Hypothesis079e529cee16ecc6b30ceda7b2efc3a0', 'My custom value 1'),
        ('Hypothesis57984238af9c8ead9a5d0182e449b19b', 'My custom value 2')
    ) AS data
)

SELECT 
    application_instances.consumer_key, 
    application_instances.tool_consumer_instance_guid,
    canned_values.tool_consumer_instance_guid
FROM 
    application_instances
LEFT OUTER JOIN canned_values
ON
    application_instances.consumer_key = canned_values.consumer_key
```

If we wanted to get fancy here and override the value from our list of canned
values we can use a `CASE` statement:

```sql
WITH
    canned_values AS (
        SELECT 
        column1 AS consumer_key,  
        column2 AS tool_consumer_instance_guid
    FROM (
        VALUES 
        ('Hypothesis079e529cee16ecc6b30ceda7b2efc3a0', 'My custom value 1'),
        ('Hypothesis57984238af9c8ead9a5d0182e449b19b', 'My custom value 2')
    ) AS data
)


SELECT 
    application_instances.consumer_key,
    CASE 
        WHEN canned_values.tool_consumer_instance_guid IS NULL
            THEN application_instances.tool_consumer_instance_guid
        ELSE canned_values.tool_consumer_instance_guid
    END AS guid
    
FROM 
    application_instances
LEFT OUTER JOIN canned_values
ON
    application_instances.consumer_key = canned_values.consumer_key
```
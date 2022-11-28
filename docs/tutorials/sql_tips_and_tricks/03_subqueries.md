# Sub-queries

I'm not going to get into every scenario where sub-queries can help (they are 
the "S" in SQL after all), but I'll point out a few choice ones.

## A join isn't always the answer

Let's say we want to get the application instances with the most groups:

```sql
SELECT 
    application_instance_id, 
    COUNT(1) as count 
FROM group_info 
GROUP BY application_instance_id 
ORDER BY count DESC
```

This is good, but what if we want:

 * The details from the application instance table
 * ... and only for the 4 most populous application instances

It's not completely clear how to do this with a plain join, but with a 
sub-query it's quite easy:

```sql
SELECT
    application_instances.*
FROM application_instances
JOIN (
    SELECT 
        application_instance_id, 
        COUNT(1) as count 
    FROM group_info 
    GROUP BY application_instance_id 
    ORDER BY count DESC
    LIMIT 4
) as top_4
    ON top_4.application_instance_id = application_instances.id
```

As a sneak peak of the next CTE section, if we allocate a nice name it's not
even necessary to join at all:

```sql
WITH
    top_4 AS (
        SELECT 
            application_instance_id, 
            COUNT(1) as count 
        FROM group_info 
        GROUP BY application_instance_id 
        ORDER BY count DESC
        LIMIT 4
    )

SELECT *
FROM application_instances
WHERE id in (SELECT application_instance_id FROM top_4)
```

## Problems with aliases

Lets say you are playing around with grouping data in LMS:

```sql
SELECT 
    authority_provided_id AS a_id,
    COUNT(1)
FROM grouping
GROUP BY a_id
```

This works fine. But if you do the following it's an error:


```sql
SELECT 
    authority_provided_id AS a_id
FROM grouping
WHERE a_id = '653e9620a656a954c684942f6443fa3e3410c03a'
```

> ERROR: column "a_id" does not exist Hint: Perhaps you meant to reference the column "grouping.id". Position: 62

Which is annoying but no great shakes, you can fix it by using the column name:

```sql
SELECT 
    authority_provided_id AS a_id
FROM grouping
WHERE authority_provided_id = '653e9620a656a954c684942f6443fa3e3410c03a'
```

But where it gets annoying is if you have something complicated in your
select like:

```sql
SELECT 
    created,
    CONCAT(
        EXTRACT(YEAR FROM created - INTERVAL '6 months'),
        '-',
        CASE
            WHEN EXTRACT(QUARTER FROM created - INTERVAL '6 months') < 2
                THEN 1
            ELSE 2
        END
    ) as created_academic_half_year
FROM "user"
WHERE 
    -- Err... what do we put here?
```

You can put the whole `CONCAT` there, and it works, but it sucks...

You can get around it with a sub-query:

```sql
SELECT * FROM (
    SELECT 
        created,
        CONCAT(
            EXTRACT(YEAR FROM created - INTERVAL '6 months'),
            '-',
            CASE
                WHEN EXTRACT(QUARTER FROM created - INTERVAL '6 months') < 2
                    THEN 1
                ELSE 2
            END
        ) as created_academic_half_year
    FROM "user"
) AS data
WHERE 
    created_academic_half_year = '2021-2'
```

Note the `AS data` there. You always need to give sub-queries a name. It 
doesn't matter what, but they must have one.
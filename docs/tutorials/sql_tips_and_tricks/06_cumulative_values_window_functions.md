# Cumulative values with window functions

## Windowing for cumulative counts

Let's say we want to count the number of users added every month:

(_This query is in `h`_)

```sql
SELECT 
    DATE_TRUNC('MONTH', registered_date) AS registered_month,
    COUNT(1) AS user_count
FROM "user"
GROUP BY registered_month
```

This is quite easy. But what if we want to know cumulative values?

Window functions can help us here, by allowing us to roll up values:

```sql
SELECT 
    DATE_TRUNC('MONTH', registered_date) AS registered_month,
    SUM(COUNT(1)) 
        OVER (ORDER BY registered_month) 
        AS user_count
FROM "user"
GROUP BY registered_month
```

But oh no! This is an exception:

> ERROR: column "registered_month" does not exist Position: 103

Sub-queries to the rescue:

```sql
SELECT
    registered_month,
    SUM(user_count) 
        OVER (ORDER BY registered_month) 
        AS user_cumulative_count
FROM (
    SELECT 
        DATE_TRUNC('MONTH', registered_date) AS registered_month,
        COUNT(1) AS user_count
    FROM "user"
    GROUP BY registered_month
) AS data
```

The `OVER` here says we want to run a window function. The default size of the 
window is starting at the first row, and ending on this row. The `ORDER BY` 
tells it which order to run the window in and so which rows are the first etc.

You can change all these if you want to. There are also more windowing 
functions like `SUM` that we can apply.

## Partition the window

Let's say we also wanted these counts by individual `authority`:

```sql
SELECT
    registered_month,
    authority,
    SUM(user_count) 
        OVER (PARTITION BY authority ORDER BY registered_month) 
        AS user_cumulative_count
FROM (
    SELECT 
        DATE_TRUNC('MONTH', registered_date) AS registered_month,
        authority,
        COUNT(1) AS user_count
    FROM "user"
    GROUP BY registered_month, authority
) AS data
```

The partition here allows the window to apply separately to each authority.

## Putting this all together for a fancy query

Let's try for some SQL bingo with the things we've learned:

```sql
WITH
    yearly_counts AS (
        SELECT 
            EXTRACT('YEAR' FROM registered_date - INTERVAL '6 months') AS academic_year,
            authority,
            COUNT(1) AS user_count
        FROM "user"
        GROUP BY academic_year, authority
    ),
    
    top_authorities AS (
        SELECT 
            authority, 
            COUNT(1) as count
        FROM "user" 
        GROUP BY authority
        ORDER BY count DESC
        LIMIT 4
    )

SELECT
    academic_year,
    authority,
    SUM(user_count) 
        OVER (PARTITION BY authority ORDER BY academic_year) 
        AS user_cumulative_count
FROM yearly_counts
WHERE 
    authority in (SELECT authority FROM top_authorities)
ORDER BY academic_year, authority
```

This query will get us:

 * The cumulative counts of registered users
 * By academic year
 * From the top 4 authorities
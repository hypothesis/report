# Slicing and dicing dates

Let's assume we want to find out about numbers of users and when they were 
created, and we'd like to group by various things. 

`EXTRACT` is great for individual parts of the date:

```sql
SELECT 
    created,
    EXTRACT(YEAR FROM created) AS created_year,
    EXTRACT(QUARTER FROM created) AS created_quarter,
    EXTRACT(MONTH FROM created) AS created_month
FROM "user"
```

| created                    | created_year | created_quarter | created_month |
|----------------------------|--------------|-----------------|---------------|
| 2021-10-27T16:03:47.419199 | 2021         | 4               | 10            |
| 2021-10-27T16:03:50.923781 | 2021         | 4               | 10            |
| 2021-10-27T16:03:56.740508 | 2021         | 4               | 10            |

`DATE_TRUNC` is great for getting a date, but rounded off to some nearest 
value.

```sql
SELECT 
    created,
    DATE_TRUNC('YEAR', created) AS created_year,
    DATE_TRUNC('QUARTER', created) AS created_quarter,
    DATE_TRUNC('MONTH', created) AS created_month
FROM "user"
```
| created                    | created_year | created_quarter | created_month |
|----------------------------|--------------|-----------------|---------------|
| 2021-10-27T16:03:47.419199 | 2021-01-01   | 2021-10-01      | 2021-10-01    |
| 2021-10-27T16:03:50.923781 | 2021-01-01   | 2021-10-01      | 2021-10-01    |
| 2021-10-27T16:03:56.740508 | 2021-01-01   | 2021-10-01      | 2021-10-01    |

## Academic dates

Often we want an academic year or quarter, and one easy way to get that is
to shift the date by 6 months.

```sql
SELECT 
    created,
    created - INTERVAL '6 months' AS created_academic
FROM "user"
```

We can combine this with the above to get things like the academic year:

```sql
SELECT 
    created,
    EXTRACT(YEAR FROM created - INTERVAL '6 months') AS created_academic_year,
    EXTRACT(QUARTER FROM created - INTERVAL '6 months') AS created_academic_quarter
FROM "user"
```

In many of our calculations we use academic half year, which is quarters 1 and 
2 in half 1 and quarters 3 and 4 in half 2. There are a few ways to get this
but one way is like this:

```sql
SELECT 
    created,
    EXTRACT(YEAR FROM created - INTERVAL '6 months') AS created_academic_year,
    CASE
        WHEN EXTRACT(QUARTER FROM created - INTERVAL '6 months') < 2
            THEN 1
        ELSE 2
    END AS created_academic_half
FROM "user"
```

If we want these expressed as one value we can combine them together to get a
single field we can sort and compare:

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
```

| created                    | created_academic_half_year |
|----------------------------|----------------------------|
| 2021-10-27T16:03:47.419199 | 2021-1                     |
| 2021-10-27T16:03:47.419199 | 2021-1                     |
| 2021-10-27T16:03:47.419199 | 2021-1                     |
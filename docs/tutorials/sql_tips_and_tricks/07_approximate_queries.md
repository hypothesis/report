# Approximate queries

## `COUNT(*)` using Postgres internal metrics

Counting all items in tables is a very crude, but quite common metric. It's 
also not particularly fast in Postgres as it still scans the table.

However Postgres keeps approximate tabs on the number of rows for a few 
internal purposes. One is for query optimisation:

```sql
SELECT 
    n_live_tup AS count
FROM pg_stat_user_tables 
WHERE 
    schemaname = 'public'
    AND relname = 'annotation'
```

This is updated whenever `ANALYZE` is run, and so will always be an under-count.

Another is something to do with allocating disk:

```sql
SELECT 
    reltuples::bigint as count
FROM pg_class
WHERE 
    oid = 'public.annotation'::regclass
```

As rows can be allocated which are then deleted, unless you have run `VACUUM`
recently, this will be an over-count.

Therefore, we can get a better approximation by averaging the two:

```sql
-- This is fast _approximate_ COUNT(*). It's less accurate than doing a full 
-- count, but doesn't take forever. It takes the average of two different approximate
-- counts in Postgres with the hope this will be more accurate

SELECT
    AVG(count)::int as count
FROM (
    -- This is a count from the stats table and is like to under-count if 
    -- we haven't run analyse recently
    SELECT 
        n_live_tup AS count
    FROM pg_stat_user_tables 
    WHERE 
        schemaname = 'public'
        AND relname = 'annotation'
    
    UNION
    
    -- This is a count of the allocated rows (I think) and is therefore
    -- likely to over-count if we haven't vacuumed the DB recently
    SELECT 
        reltuples::bigint as count
    FROM pg_class
    WHERE 
        oid = 'public.annotation'::regclass
) AS data
```

## Using sampling

The above tricks are only useful if you want the approximate table size. For
anything more fine-grained it won't work.

The `annotations` table is horribly slow at the moment and if you don't need
an exact number, sampling can be useful.

Let's say we want a count of the annotations per month:

```sql
SELECT
    DATE_TRUNC('month', created) as created_date,
    COUNT(*) as count
FROM 
    annotation
GROUP BY created_date
ORDER BY created_date
```

If you try and run this in production this is pretty much going to timeout.

### `TABLESAMPLE` to the rescue

So instead we can use `TABLESAMPLE` to select rows at random to count. The 
syntax is a bit weird:

```sql
SELECT
    DATE_TRUNC('month', created) as created_date,
    COUNT(*) * 500 as count
FROM 
    annotation TABLESAMPLE SYSTEM (0.2)  -- 0.2%
GROUP BY created_date
ORDER BY created_date
```

Here the `0.2` is 0.2%, so 1 in every 500 rows. This will reduce our count by
500 times, so to get back to a normal value we have to scale our number up 
again.

The `SYSTEM` is a sampling method. There are two methods:

 * `SYSTEM` - Picks random pages from physical storage
 * `BERNOULLI` - Performs more statisically valid randomization based on rows

Using `SYSTEM` selects blocks of data from the disk at random. This is good
because it's very fast, but you might get a block full of delete items which
don't count, or values all next to each other.

`BERNOULLI` is ideal because it's actually random over the rows, not the disk,
but I've found it to be so slow as to be un-usable.

### This isn't really statistically valid

As a result of using `SYSTEM` this isn't particularly valid. There are some
things you can do to try and tune this if you want to:

 * Make sure you average over larger things - Sampling over very small groups
   will ensure your results are nearly random. Sampling over the whole table is
   more likely to be representative
 * Sample as big as you can be bothered to wait for
 * You can test the over or under count and then extrapolate



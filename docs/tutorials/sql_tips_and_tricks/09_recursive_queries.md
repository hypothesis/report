# Recursive queries

It can be difficult to write queries for data which has a parent-child 
relationship. For example our `grouping` table has a `parent_id`.

A pretty normal thing to want is to get a grouping and all it's children
(no matter how deep they are). At the moment these are only one level deep, but
lets pretend for a moment.

We can do this with a recursive query.

## They are CTE's with a fixed shape

Recursive queries in Postgres are CTE's with a very fixed shape. We start with
a normal query which acts as our base case in a CTE:

```sql
WITH
    grouping_tree AS (
        -- Base case - normal non-recursive query
        SELECT id, parent_id, lms_name
        FROM grouping 
        WHERE id = 817
    )
    
SELECT * FROM grouping_tree
```

Then we introduce a new recursive portion with a `UNION` which refers to the
named CTE:

```sql
WITH RECURSIVE
    grouping_tree AS (
        -- Base case - normal non-recursive query
        SELECT id, parent_id, lms_name
        FROM grouping 
        WHERE id = 817
        
        UNION
        
        -- Recursive case
        SELECT grouping.id, grouping.parent_id, grouping.lms_name
        FROM grouping
        JOIN grouping_tree ON
            grouping.parent_id = grouping_tree.id
    )
    
SELECT * FROM grouping_tree
```

Notice the addition of the `RECURSIVE` keyword. This doesn't make it recursive,
it just allows you to reference a CTE from itself. You only need it once and
you can have multiple CTEs, some of which aren't recursive.

As far as I know this is the only shape this can take:

```sql
WITH RECURSIVE 
    name AS (
        -- Base case - normal non-recursive query
        SELECT ...
        
        UNION [ALL?]
        
        -- Recursive case
        SELECT ...
    )
```

If you add more `UNION` clauses I think everything bar the last one is 
interpreted as the base case.

The way this works is the base case is selected first, and then Postgres will
cycle through the recursive portion until no results get added to the set.

It's therefore up to you to:

 * Make sure the query terminates
 * Make sure the columns line up in both portions

## Mind your union

It's important that the query terminates, but with a plain `UNION` this is 
quite hard to mess up, as even if you select the exact same data set twice the
union will deduplicate it, meaning the set won't grow, and so the recursion
will terminate.

You can use `UNION ALL` you might need to be more careful. 

## A real worked example

A real problem we have with old application instances is that they have more 
than one GUID and they can change over time. Sometimes the GUIDs in the table
are blank. So to get a complete picture of all the GUIDs which have ever been 
associated with another one we need to:

 * Check in both `application_instances` and `group_info`
 * For a single application instance find all GUIDs ever associated with it
 * Find all application instances associated with those GUIDs
 * Keep going until we don't find any more

This pretty much impossible without a recursive query. We can put together a
lot of our SQL foo to get this to happen.

We'll start with getting the application instances with direct matches:

```sql
WITH
    all_guids AS (
        SELECT 
            application_instance_id,
            tool_consumer_instance_guid AS guid
        FROM group_info
        
        UNION
        
        SELECT id, tool_consumer_instance_guid
        FROM application_instances
    )
    
SELECT * FROM all_guids WHERE guid = 'localhost'
```

We can start building our base case for a recursive CTE:

```sql
WITH RECURSIVE
    all_guids AS (
        SELECT 
            application_instance_id,
            tool_consumer_instance_guid AS guid
        FROM group_info
        
        UNION
        
        SELECT id, tool_consumer_instance_guid
        FROM application_instances
    ),
    
    linked_guids AS (
        -- Base case
        SELECT * 
        FROM all_guids
        WHERE guid = 'localhost'
    )
    

SELECT * FROM linked_guids 
```

Now we need to join back onto the list if either:

 * The application instance id is the same (to get other guids)
 * Or the guid is the same (to get other application instances)

```sql
WITH RECURSIVE
    all_guids AS (
        SELECT 
            application_instance_id,
            tool_consumer_instance_guid AS guid
        FROM group_info
        
        UNION
        
        SELECT id, tool_consumer_instance_guid
        FROM application_instances
    ),
    
    linked_guids AS (
        -- Base case
        SELECT * 
        FROM all_guids
        WHERE guid = 'localhost'
        
        UNION
        
        -- Recursive case
        SELECT all_guids.* FROM all_guids
        JOIN linked_guids ON 
            linked_guids.application_instance_id = all_guids.application_instance_id
            OR linked_guids.guid = all_guids.guid 
    )
    
SELECT * FROM linked_guids 
```

It turns out quite a few GUIDs are blank or NULL, so we'll do a little more
clean up with our join condition, and we are done:

```sql
WITH RECURSIVE
    all_guids AS (
        SELECT 
            application_instance_id,
            tool_consumer_instance_guid AS guid
        FROM group_info
        
        UNION
        
        SELECT id, tool_consumer_instance_guid
        FROM application_instances
    ),
    
    linked_guids AS (
        -- Base case
        SELECT * 
        FROM all_guids
        WHERE guid = 'localhost'
        
        UNION
        
        -- Recursive case
        SELECT all_guids.* FROM all_guids
        JOIN linked_guids ON 
            (
                linked_guids.application_instance_id = all_guids.application_instance_id
                OR linked_guids.guid = all_guids.guid 
            )
            AND linked_guids.guid != ''
            AND linked_guids IS NOT NULL
    )

SELECT * FROM linked_guids 
```
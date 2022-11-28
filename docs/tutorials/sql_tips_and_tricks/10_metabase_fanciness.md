# Getting all fancy with Metabase

## Variables

We introduced some pretty beefy queries in previous entries for getting
linked GUIDs for example.

That query returned the GUIDs linked directly or indirectly to the GUID 
`localhost`.

It's quite easy to parameterise a value in Metabase with some formatting:

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
        WHERE guid = {{guid}}
        
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

Notice the `{{guid}}` there. To make this work you additionally need to tell
Metabase that the field is:

 * A string
 * Required
 * And provide a default

## Conditional variables

You can make sections of a query conditional if the variable is not "required"
but the query needs to make sense without that portion. You can often get
around this in where clauses by adding `1=1`. 

Let's add application instance id as another variable and make them both 
optional:

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
        WHERE 
            1=1
            [[AND guid = {{guid}}]]
            [[AND application_instance_id = {{application_instance_id}}]]
        
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

Remember to set the `application_instance_id` variable to be numeric.

This allows a user to type in either value (or both) and can make a quite 
useful tool from a query.
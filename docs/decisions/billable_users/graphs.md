```sql
SELECT 
    DATE_TRUNC('month', timestamp) as mo,
    count(1) filter (where course_id is null) AS nool,
    COUNT(1) filter (where course_id is not null) as not_nool  
FROM event
WHERE type_id = 1
GROUP BY mo
ORDER BY mo
```

![Percentage events with courses](./events_with_course.png)
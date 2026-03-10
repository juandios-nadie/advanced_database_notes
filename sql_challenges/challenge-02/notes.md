# Session – 2026-06-17

## Topics covered
- Tables
- Primary keys
- JOIN
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- SELF JOIN
- Selecting columns with table aliases
- Multi-table queries
- `WHERE`
- `ORDER BY`
- `DISTINCT`
- `GROUP BY`
- `NULL`

## What I understood
- Tables store data in rows and columns.
- A primary key uniquely identifies each row in a table.
- A `JOIN` combines data from two tables based on a related column.
- `INNER JOIN` returns only the rows that match in both tables.
- `LEFT JOIN` returns all rows from the left table and the matching rows from the right table. If there is no match, the right side shows `NULL`.
- A `SELF JOIN` is a join where a table is joined with itself.
- Writing `table_alias.column_name` selects a specific column from a specific table.
- `WHERE` is used to filter rows.
- `ORDER BY ... DESC` sorts results from highest to lowest.
- `DISTINCT` removes duplicate results.

## What is still confusing
- When to use `LEFT JOIN` instead of `INNER JOIN`
- How `RIGHT JOIN` is different from `LEFT JOIN` in practice
- When to use `DISTINCT` vs `GROUP BY`
- How aliases should be used correctly in JOINs
- How `NULL` values appear in OUTER JOIN results

## Questions
- When should I use `INNER JOIN` instead of `LEFT JOIN`?
- Why does `LEFT JOIN` return `NULL` values?
- What is the difference between `DISTINCT` and `GROUP BY`?
- How does a `SELF JOIN` work in a real example?
- Can every `RIGHT JOIN` be rewritten as a `LEFT JOIN` by switching table order?

## Related concepts
- Foreign key
- Aliases
- Filtering with `WHERE`
- Sorting with `ORDER BY`
- Removing duplicates with `DISTINCT`
- Grouping with `GROUP BY`
- Missing values with `NULL`

## Resources used
- SQL practice exercises
- Class notes
- `resources/`

## Notes and examples

### SECTION 6: Multi-table queries with JOINs

**Find the domestic and international sales for each movie**
```sql
SELECT movies.title, boxoffice.domestic_sales, boxoffice.international_sales
FROM movies
INNER JOIN boxoffice
ON movies.id = boxoffice.movie_id;
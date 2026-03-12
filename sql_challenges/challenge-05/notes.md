# Session – 2026-03-10

## Topics covered
- Set operators
- `UNION`
- `UNION ALL`
- `MINUS`
- `INTERSECT`
- Removing duplicates
- Keeping duplicates
- Comparing results from two queries
- Ordering combined results

## What I understood
- Set operators combine the results of two `SELECT` statements.
- `UNION` combines results and removes duplicates.
- `UNION ALL` combines results and keeps duplicates.
- `MINUS` returns rows from the first query that are not in the second query.
- `INTERSECT` returns only the rows that appear in both queries.
- Both queries in a set operator should return the same number of columns and compatible data types.
- `ORDER BY` is placed at the end of the full set operation, not after each individual `SELECT`.

## What is still confusing
- When to use `UNION` instead of `UNION ALL`
- How duplicates are determined in set operators
- Why `MINUS` depends on the order of the two queries
- Whether all SQL systems support `MINUS` the same way
- How performance differs between `UNION` and `UNION ALL`

## Questions
- What is the practical difference between `UNION` and `UNION ALL`?
- Why does `UNION` remove duplicates but `UNION ALL` does not?
- Why does changing the order in `MINUS` change the result?
- Is `MINUS` the same as `EXCEPT` in other databases?
- Can I use set operators with more than one column?

## Related concepts
- `DISTINCT`
- Result sets
- Sorting with `ORDER BY`
- Duplicate values
- Query compatibility

## Resources used
- SQL practice exercises
- Class notes
- `resources/`

## Notes and examples

### `UNION`

**Combine colours from both collections and remove duplicates**
```sql
select colour from my_brick_collection
union
select distinct colour from your_brick_collection
order by colour;
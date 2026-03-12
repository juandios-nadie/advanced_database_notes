# Session – YYYY-MM-DD

## Topics covered
- Window functions
- `OVER()`
- `PARTITION BY`
- Window aggregates
- `COUNT() OVER()`
- `MEDIAN() OVER()`
- `AVG() OVER()`
- `SUM() OVER()`
- Running totals
- Running averages
- Window frames
- `ROWS BETWEEN`
- `RANGE BETWEEN`
- Common Table Expressions (`WITH`)
- Filtering results from window functions using a CTE
- Ranking functions
- `DENSE_RANK()`
- Top-N per group
- `JOIN`

## What I understood
- A window function performs a calculation across a set of rows related to the current row without collapsing the result into one row per group.
- `OVER()` is what makes a function act as a window function.
- `PARTITION BY` splits the result set into groups, and the window function is calculated separately for each group.
- `COUNT(*) OVER (PARTITION BY shape)` gives the number of bricks for each shape while still showing every row.
- `MEDIAN(weight) OVER (PARTITION BY shape)` gives the median weight inside each shape group.
- `ORDER BY` inside `OVER()` defines the order used by the window calculation, which is different from the final `ORDER BY` of the query.
- `AVG(weight) OVER (ORDER BY brick_id)` can be used to calculate a running average.
- `ROWS BETWEEN ...` defines the window using physical rows.
- `RANGE BETWEEN ...` defines the window using values, not row positions.
- `SUM(weight) OVER (...)` can be used to calculate running totals.
- A `WITH` clause helps organize complex queries and makes it easier to filter the results of window functions.
- `DENSE_RANK()` assigns the same rank to tied values and does not skip the next rank number.
- `DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC)` can be used to find the top salaries inside each department.
- A `JOIN` combines related data from different tables, such as employees and departments.

## What is still confusing
- The exact difference between `ROWS BETWEEN` and `RANGE BETWEEN`
- When `RANGE` is better than `ROWS`
- Why filtering window function results is usually done with a CTE instead of directly in `WHERE`
- How `MEDIAN()` behaves when there is an even number of rows in a partition
- The difference between `DENSE_RANK()`, `RANK()`, and `ROW_NUMBER()`
- How ties affect top-N queries by department

## Questions
- What is the practical difference between `ROWS` and `RANGE` in a window frame?
- When should I use `DENSE_RANK()` instead of `RANK()` or `ROW_NUMBER()`?
- Why can I not directly filter most window function results in the same `SELECT` with `WHERE`?
- How is `MEDIAN()` calculated when a partition has an even number of values?
- What happens if two employees have the same salary in the top-3-per-department query?
- Can window functions be combined with `GROUP BY`, and when is that useful?

## Related concepts
- Aggregate functions
- Grouping
- Sorting
- Query execution order
- Window frames
- CTE
- Ranking functions
- Joins

## Resources used
- SQL practice exercises
- Class notes
- `resources/`

## Notes and examples

### Create and populate the `bricks` table
```sql
drop table bricks cascade constraints;

create table bricks (
  brick_id integer,
  colour   varchar2(10),
  shape    varchar2(10),
  weight   integer
);

insert into bricks values ( 1, 'blue', 'cube', 1 );
insert into bricks values ( 2, 'blue', 'pyramid', 2 );
insert into bricks values ( 3, 'red', 'cube', 1 );
insert into bricks values ( 4, 'red', 'cube', 2 );
insert into bricks values ( 5, 'red', 'pyramid', 3 );
insert into bricks values ( 6, 'green', 'pyramid', 1 );

commit;
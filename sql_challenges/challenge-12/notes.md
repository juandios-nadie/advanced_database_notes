# Notes – SQL JOINs

## Tables

A table stores data in rows and columns.

Each row is one record.

Example:

| id | name | team |
|---|---|---|
| 1 | Ana | Engineering |
| 2 | Luis | Product |

## Primary Key

A primary key is the unique identifier of a row.

Usually it is called `id`.

Example:

~~~sql
users.id
~~~

This means each user has a unique ID.

## Foreign Key

A foreign key is a column that connects one table to another table.

Example:

~~~sql
tasks.assigned_to = users.id
~~~

This means the task is assigned to a specific user.

## JOIN

A `JOIN` is used to combine information from two or more tables.

It works by matching related columns.

Example:

~~~sql
SELECT 
    users.full_name,
    tasks.title
FROM users
JOIN tasks
    ON users.id = tasks.assigned_to;
~~~

This shows each task with the name of the person assigned to it.

## INNER JOIN

`INNER JOIN` only returns rows that have a match in both tables.

If there is no match, the row does not appear.

Example:

~~~sql
SELECT 
    movies.title,
    boxoffice.rating
FROM movies
INNER JOIN boxoffice
    ON movies.id = boxoffice.movie_id;
~~~

This shows only movies that have box office information.

## LEFT JOIN

`LEFT JOIN` returns all rows from the left table.

If there is a match in the right table, it shows the matching data.

If there is no match, the right table columns show `NULL`.

Example:

~~~sql
SELECT 
    buildings.building_name,
    employees.role
FROM buildings
LEFT JOIN employees
    ON buildings.building_name = employees.building;
~~~

This shows all buildings, even buildings with no employees.

## RIGHT JOIN

`RIGHT JOIN` returns all rows from the right table.

It is like `LEFT JOIN`, but reversed.

Example:

~~~sql
SELECT 
    buildings.building_name,
    employees.role
FROM employees
RIGHT JOIN buildings
    ON employees.building = buildings.building_name;
~~~

This also shows all buildings, even if they have no employees.

Most of the time, `RIGHT JOIN` can be rewritten as a `LEFT JOIN`.

## SELF JOIN

A `SELF JOIN` is when a table is joined with itself.

This is useful when rows in the same table are related to each other.

Example:

~~~sql
SELECT 
    e.full_name AS employee,
    m.full_name AS manager
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.id;
~~~

This shows each employee and their manager.

## Aliases

Aliases are short names for tables.

They make queries easier to read.

Example:

~~~sql
SELECT 
    m.title,
    b.rating
FROM movies m
INNER JOIN boxoffice b
    ON m.id = b.movie_id;
~~~

Here:

~~~text
m = movies
b = boxoffice
~~~

So:

~~~sql
m.title
~~~

means the `title` column from the `movies` table.

## WHERE

`WHERE` filters the result.

Example:

~~~sql
SELECT 
    m.title,
    b.domestic_sales,
    b.international_sales
FROM movies m
INNER JOIN boxoffice b
    ON m.id = b.movie_id
WHERE b.international_sales > b.domestic_sales;
~~~

This shows movies that made more money internationally than domestically.

## ORDER BY

`ORDER BY` sorts the result.

Example:

~~~sql
SELECT 
    m.title,
    b.rating
FROM movies m
INNER JOIN boxoffice b
    ON m.id = b.movie_id
ORDER BY b.rating DESC;
~~~

This shows movies from highest rating to lowest rating.

## DISTINCT

`DISTINCT` removes duplicate rows.

Example:

~~~sql
SELECT DISTINCT
    building_name
FROM buildings;
~~~

This shows each building only once.

## GROUP BY

`GROUP BY` groups rows that have the same value.

It is usually used with aggregate functions like:

~~~sql
COUNT()
SUM()
AVG()
MIN()
MAX()
~~~

Example:

~~~sql
SELECT 
    building,
    COUNT(*) AS employee_count
FROM employees
GROUP BY building;
~~~

This counts how many employees are in each building.

## NULL

`NULL` means missing or no value.

In a `LEFT JOIN`, `NULL` appears when there is no matching row in the right table.

Example:

~~~sql
SELECT 
    p.page_id
FROM pages p
LEFT JOIN page_likes pl
    ON p.page_id = pl.page_id
WHERE pl.page_id IS NULL;
~~~

This finds pages with no likes.

## Page With No Likes

To find records that do not have a match in another table, use:

~~~sql
LEFT JOIN
WHERE right_table.column IS NULL
~~~

Example:

~~~sql
SELECT 
    p.page_id
FROM pages p
LEFT JOIN page_likes pl
    ON p.page_id = pl.page_id
WHERE pl.page_id IS NULL;
~~~

This works because pages with no likes will not have a matching row in `page_likes`.

So `pl.page_id` becomes `NULL`.

## Main idea

Use `INNER JOIN` when you only want matching records.

Use `LEFT JOIN` when you want to keep everything from the first table, even if there is no match.

Use `SELF JOIN` when a table needs to connect to itself.

Use `WHERE column IS NULL` after a `LEFT JOIN` to find missing relationships.
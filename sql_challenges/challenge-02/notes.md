# Session – 2026-06-17

## Topics covered
- tables
- JOIN
- . 
- INNER JOIN
- LEFT JOIN
- SELF JOIN
- RIGHT JOIN


## What I understood
- Tables have primary keys that are the id of a row
- La INNER JOIN palabra clave selecciona registros que tienen valores coincidentes en ambas tablas.
- if add t1.___ anything is grab just that collumn
- The LEFT JOIN keyword returns all records from the left table (table1), and the matching records from the right table (table2). The result is 0 records from the right side, if there is no match.
- Self join is a regular join, but the table is joined with itself.

## What is still confusing
- 

## Questions
- 

## Related concepts
- [Concept name](../concepts/concept-name.md)

## Resources used
- See `resources/`

### SECTION 6: 
##### Multi-table queries with JOINs

* Find the domestic and international sales for each movie
    ```sql
    SELECT movies.Title, boxoffice.domestic_sales , boxoffice.international_sales FROM movies INNER JOIN boxoffice ON movies.Id = boxoffice.movie_id;
    ```
* Show the sales numbers for each movie that did better internationally rather than domestically
    ```sql
    SELECT movies.Title, boxoffice.domestic_sales,boxoffice.international_sales FROM movies INNER JOIN boxoffice ON movies.Id = boxoffice.movie_id WHERE boxoffice.domestic_sales < boxoffice.international_sales ; 
    ```
* List all the movies by their ratings in descending order
    ```sql
    SELECT movies.Title, boxoffice.rating FROM movies INNER JOIN boxoffice ON movies.Id = boxoffice.movie_id  ORDER BY boxoffice.rating DESC;
    ```
### SECTION 7: 
##### SQL Lesson 7: OUTER JOINs

* Find the domestic and international sales for each movie
    ```sql
    SELECT DISTINCT(b.building_name) bn FROM employees e LEFT JOIN buildings b ON bn = e.building;
    ```
* Find the list of all buildings and their capacity
    ```sql
    SELECT * FROM buildings;
    ```
* List all buildings and the distinct employee roles in each building (including empty buildings)
    ```sql
    SELECT b.building_name bn, e.role r FROM buildings b  LEFT JOIN employees e ON bn = e.building GROUP BY bn,r;
    ```







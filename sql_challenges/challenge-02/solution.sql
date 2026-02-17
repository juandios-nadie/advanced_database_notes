SELECT movies.Title, boxoffice.domestic_sales , boxoffice.international_sales FROM movies INNER JOIN boxoffice ON movies.Id = boxoffice.movie_id

SELECT movies.Title, boxoffice.domestic_sales,boxoffice.international_sales FROM movies INNER JOIN boxoffice ON movies.Id = boxoffice.movie_id WHERE boxoffice.domestic_sales < boxoffice.international_sales ; 

SELECT movies.Title, boxoffice.rating
FROM movies
INNER JOIN boxoffice ON movies.Id = boxoffice.movie_id 
ORDER BY boxoffice.rating DESC;

SELECT DISTINCT(b.building_name) bn
FROM employees e
LEFT JOIN buildings b
ON bn = e.building;

SELECT * FROM buildings;

SELECT b.building_name bn, e.role r
FROM buildings b 
LEFT JOIN employees e
ON bn = e.building
GROUP BY bn,r;
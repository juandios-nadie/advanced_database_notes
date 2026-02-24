
# Find the longest time that an employee has been at the studio
- SELECT MAX(years_employed) FROM employees;

# For each role, find the average number of years employed by employees in that role
SELECT AVG(years_employed) , role
FROM employees
GROUP BY role
;

# Find the total number of employee years worked in each building
SELECT building , SUM(years_employed) 
FROM employees
GROUP BY building
;

# Find the number of Artists in the studio (without a HAVING clause)
SELECT Count(role)
FROM employees
where role = 'Artist'
;

# Find the number of Employees of each role in the studio
SELECT role ,Count(role)
FROM employees
GROUP By role
;

# Find the total number of years employed by all Engineers
SELECT role , Sum(Years_employed)
FROM employees
Where role = 'Engineer'
;


# 4 . Try It!
- Complete the following query to return the:
- Number of different shapes
- The standard deviation (stddev) of the unique weights

select COUNT(distinct shape) number_of_shapes,
        STDDEV(unique weight) distinct_weight_stddev
from   bricks;

# 6 . Try It!
- Complete the following query to return the total weight for each shape stored in the bricks table:

select shape, SUM(weight) shape_weight
from   bricks
group by shape;

# 8 . Try It!
- Complete the following query to find the shapes which have a total weight less than four:

select shape, sum ( weight ) sw
from   bricks
group  by shape
having sw < 4;
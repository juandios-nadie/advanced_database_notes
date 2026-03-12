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

select b.*,
       count(*) over (
         partition by shape
       ) bricks_per_shape,
       median ( weight ) over (
         partition by shape
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;

select b.brick_id, b.weight,
       round ( avg ( weight ) over (
         order by BRICK_ID
       ), 2 ) running_average_weight
from   bricks b
order  by brick_id;


select b.*,
       min ( colour ) over (
         order by brick_id
         rows between 2 preceding and 1 preceding
       ) first_colour_two_prev,
       count (*) over (
         order by weight
         range between current row and 1 following
       ) count_values_this_and_next
from   bricks b
order  by weight;

with totals as (
  select b.*,
         sum(weight) over (
           partition by shape
         ) weight_per_shape,
         sum(weight) over (
           partition by shape
           order by brick_id
           rows between unbounded preceding and current row
         ) running_weight_by_id
  from   bricks b
)
select * from   totals
where  weight_per_shape > 4
and    running_weight_by_id > 4
order  by brick_id;



with ranked as (
  select
      d.department_name,
      e.name,
      e.salary,
      dense_rank() over (
        partition by e.department_id
        order by e.salary desc
      ) as sal_rank
  from employee e
  join department d
    on d.department_id = e.department_id
)

select
    department_name,
    name,
    salary
from ranked
where sal_rank <= 3
order by
    department_name asc,
    salary desc,
    name asc;

create table A
(
	dimension_1 varchar(5)
	,dimension_2 varchar(5)
	,dimension_3 varchar(5)
	,measure_1 int
);

create table B
(
	dimension_1 varchar(5)
	,dimension_2 varchar(5)
	,measure_2 int
);

create table MAP
(
	dimension_1 varchar(5)
	,correct_dimension_2 varchar(5)
);

insert into A values ('a','I','K', 1);
insert into A values ('a','J','L', 7);
insert into A values ('b','I','M', 2);
insert into A values ('c','J','N', 5);

insert into B values ('a','J',7 );
insert into B values ('b','J',10);
insert into B values ('d','J',4 );


insert into MAP values ('a','W');
insert into MAP values ('a','W');
insert into MAP values ('b','X');
insert into MAP values ('c','Y');
insert into MAP values ('b','X');
insert into MAP values ('d','Z');


select * from A;
select * from B;
select * from MAP;

with ct1 as
(
	select a.dimension_1, map.correct_dimension_2, a.measure_1
	from A as a join MAP as map 
		on a.dimension_1 = map.dimension_1
	group by a.dimension_1, map.correct_dimension_2, measure_1
),
ct2 as 
(
	select b.dimension_1, map.correct_dimension_2 ,measure_2 
	from B as b join MAP as map 
		on b.dimension_1 = map.dimension_1
	group by b.dimension_1, map.correct_dimension_2, measure_2
),
ct3 as
(
	select isnull(a.dimension_1, b.dimension_1) dimension_1,
		   isnull(a.correct_dimension_2, b.correct_dimension_2) dimension_2, 
		   isnull(a.measure_1, 0) measure_1,
		   isnull(b.measure_2, 0) measure_2 
	from ct1 a full outer join ct2 b 
	on a.dimension_1 = b.dimension_1 and a.correct_dimension_2 = b.correct_dimension_2
)
select dimension_1, 
	   dimension_2, 
	   sum(distinct(measure_1)) as measure_1,-- over (partition by dimension_1), 
	   sum(distinct(measure_2)) as measure_2
from ct3
group by dimension_1, dimension_2;



with ct1 as
(
	select t.dimension_1, t.correct_dimension_2, sum(t.measure_1)  as measure_1 from 
	(
	select a.dimension_1, map.correct_dimension_2, a.measure_1
	from A as a join MAP as map 
		on a.dimension_1 = map.dimension_1
	group by a.dimension_1, map.correct_dimension_2, measure_1
	) t
	group by t.dimension_1, t.correct_dimension_2
),
ct2 as 
(
	select t.dimension_1, t.correct_dimension_2, sum(t.measure_2)  as measure_2 from 
	(
	select b.dimension_1, map.correct_dimension_2 ,measure_2 
	from B as b join MAP as map 
		on b.dimension_1 = map.dimension_1
	group by b.dimension_1, map.correct_dimension_2, measure_2
	) t
	group by t.dimension_1, t.correct_dimension_2
),
ct3 as
(
	select isnull(a.dimension_1, b.dimension_1) dimension_1,
		   isnull(a.correct_dimension_2, b.correct_dimension_2) dimension_2, 
		   isnull(a.measure_1, 0) measure_1,
		   isnull(b.measure_2, 0) measure_2 
	from ct1 a full outer join ct2 b 
	on a.dimension_1 = b.dimension_1 and a.correct_dimension_2 = b.correct_dimension_2
)
select dimension_1, 
	   dimension_2, 
	   measure_1,
	   measure_2
from ct3;
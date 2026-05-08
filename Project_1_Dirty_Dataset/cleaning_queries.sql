select * 
from raw_data;


-- CREATING AN STAGING TABLE SO RAW DATA REMAINS UN AFFECTED
create table staging
like raw_data;

insert staging
select *
from raw_data;

select *
from staging;

-- CHECK FOR THE DUPLICATES 

select *,
row_number() over(partition by `rank`,
`peak`,
`All Time Peak`,
`Actual gross`,
`Actual gross(in 2022 dollars)`,
`Artist`,
`Tour title`,
`Year(s)`,
`Shows`,
`Average gross`,
`Ref.`
)
from staging;

with duplicate_CTE as
(
select *,
row_number() over(partition by `rank`,
`peak`,
`All Time Peak`,
`Actual gross`,
`Actual gross(in 2022 dollars)`,
`Artist`,
`Tour title`,
`Year(s)`,
`Shows`,
`Average gross`,
`Ref.`
)as row_num
from staging
)
select *
from duplicate_CTE
where `row_num` > 1
;

CREATE TABLE `staging2` (
  `Rank` int DEFAULT NULL,
  `Peak` text,
  `All Time Peak` text,
  `Actual gross` text,
  `Actual gross(in 2022 dollars)` text,
  `Artist` text,
  `Tour title` text,
  `Year(s)` text,
  `Shows` int DEFAULT NULL,
  `Average gross` text,
  `Ref.` json DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert staging2
select *,
row_number() over(partition by `rank`,
`peak`,
`All Time Peak`,
`Actual gross`,
`Actual gross(in 2022 dollars)`,
`Artist`,
`Tour title`,
`Year(s)`,
`Shows`,
`Average gross`,
`Ref.`
)as row_num
from staging;

select *
from staging2;

-- DATA STANDARDRIZE

select distinct artist,
replace(`artist` , '©' , '')
from staging2;

update staging2
set `artist` = replace(`artist` , '©' , '');

update staging2
set `artist` = trim(`artist`);

update staging2
set `Tour title` = replace(`Tour title` , '*' , '');


update staging2
set `Tour title` = replace(`Tour title` , '¡[21][a]' , '');

update staging2
set `Tour title` = trim(`Tour title`);

update staging2
set `Year(s)` = replace(`Year(s)` , 'â€“' , '-');

select peak,
regexp_replace(`Peak` , '\\[.*\\]' , '')
from staging2;

update staging2
set `peak` = regexp_replace(`Peak` , '\\[.*\\]' , '');

update staging2
set `All Time peak` = regexp_replace(`All Time peak` , '\\[.*\\]' , '');


alter table staging2
drop column row_num;

alter table staging2
modify column `Ref.` text;

update staging2
set `Ref.` = replace(`Ref.`,'[' , '');
update staging2
set `Ref.` = replace(`Ref.`,']' , '');

update staging2
set `Ref.` = trim(`Ref.`);


select *
from staging2;

select *
from raw_data;


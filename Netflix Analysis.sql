use netflix_db;
create table netflix(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
);
show variables like 'secure_file_priv';
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix.csv"
into table netflix
fields terminated by','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;
select * from netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
select distinct type, count(type) as movies_vs_shows
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
select type, rating
from 
(select type, rating, count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by 1,2
)as t1
where ranking = 1;
select * from netflix;

-- 3. List all movies released in a specific year (e.g., 2020)
select * from netflix
where type = "Movie" and release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, COUNT(show_id) as most_content
FROM (
    SELECT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) as country
    FROM netflix
    INNER JOIN (
        SELECT 1 as n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) numbers ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1
) as countries
GROUP BY country
ORDER BY most_content DESC
LIMIT 5;

-- 5. Identify the longest movie
select * from
netflix
where type = "Movie"
and duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 years
select * from netflix
where str_to_date(date_added, '%M %D %Y') >= curdate() - interval 5 year;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix
where director = 'Rajiv Chilaka';

select * from netflix
where director like '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select * from netflix
where type = 'TV Show' and cast(substring_index(duration, ' ' , 1) as unsigned)  > 5;

-- 9. Count the number of content items in each genre
SELECT genre, COUNT(show_id)
FROM (
    SELECT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) as genre
    FROM netflix
    INNER JOIN (
        SELECT 1 as n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) numbers ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
) as genres
GROUP BY genre;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
SELECT 
    release_year, 
    AVG(content_count) AS avg_content_release
FROM (
    SELECT 
        release_year, 
        COUNT(show_id) AS content_count
    FROM netflix
    WHERE country = 'India'
    GROUP BY release_year
) AS yearly_content
GROUP BY release_year
ORDER BY avg_content_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries
select * from netflix
where type = 'Movie' and listed_in like '%Documentaries%';

-- 12. Find all content without a director
select * from netflix
where director = '';

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix
where type = 'Movie' and
cast like '%Salman Khan%'
and release_year >= year(current_date()) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT Celebraty, COUNT(*)
FROM (
    SELECT *, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', numbers.n), ',', -1)) as Celebraty
    FROM netflix
    INNER JOIN (
        SELECT 1 as n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) numbers ON CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ',', '')) >= numbers.n - 1
) as characters
where country like '%India%' and type = 'Movie'
GROUP BY celebraty
order by count(*) desc
limit 10;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
with decision 
as 
(select 
description,
case
when description like '%kill%' or description like '%violence%' then 'Bad'
else 'Good'
end as Category
from netflix)
select category, count(category) as Divion_of_good_bad 
from decision 
group by category;
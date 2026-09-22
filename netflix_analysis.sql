-- Netflix SQL — 35 Business Problems

-- 1. Count the number of Movies vs TV Shows.

-- 2. Find the most common rating for Movies and TV Shows.

-- 3. List all movies released in 2020.

-- 4. Find the top 5 countries with the most content on Netflix.

-- 5. Identify the longest movie.

-- 6. Find content added to Netflix in the last 5 years.

-- 7. Find all Movies and TV Shows directed by **Rajiv Chilaka**.

-- 8. List all TV Shows with more than 5 seasons.

-- 9. Count the number of content items in each genre.

-- 10. Find each year and the average number of content releases in India. Return the top 5 years with the highest average content release.

-- 11. List all movies that are documentaries.

-- 12. Find all content without a director.

-- 13. Find how many movies **Salman Khan** appeared in during the last 10 years.

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

-- 15. Categorize content as **Bad** if the description contains the keywords `kill` or `violence`, otherwise categorize it as **Good**, and count each category.

-- 16. Calculate the percentage of Netflix content that is Movies vs TV Shows.

-- 17. Find the year in which Netflix added the most titles.

-- 18. Find the percentage of Netflix titles that belong to each content rating.

-- 19. Find the average number of titles released per year for each rating.

-- 20. Find the countries that have produced the most Movies and TV Shows separately.

-- 21. Find the average movie duration for each release year.

-- 22. For each rating, find the number of Movies, TV Shows, and total titles.

-- 23. Find all movies that are longer than the average movie duration.

-- 24. Find the top 10 TV Shows with the highest number of seasons.

-- 25. Find the top 10 countries with the greatest genre diversity..

-- 26.  Find the release years where the number of TV Shows was greater than the number of Movies.

-- 27. Find titles that were added to Netflix within one year of their original release.





-- --------------
-- problems
-- --------------


-- 1. Count the number of Movies vs TV Shows.
SELECT
    type,
    COUNT(type) AS total_content
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for Movies and TV Shows.
SELECT
    type,
    rating,
    COUNT(rating) AS total,
    ROW_NUMBER() OVER (
        PARTITION BY type
        ORDER BY COUNT(rating) DESC
    ) AS ranking
FROM netflix
GROUP BY type, rating;


-- 3. List all movies released in 2020.
select title from netflix where release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix.
select country,count(title)  as num_movies from netflix 
group by country 
order by num_movies 
desc limit 5 ;


-- 5. Identify the longest movie.
select title , duration from netflix where type = 'Movie' and duration != 'null' 
order by split_part(duration,' ',1)::int desc limit 1 ;



-- 6. Find content added to Netflix in the last 5 years.
SELECT
    title,
    date_added
FROM netflix
WHERE to_date(date_added,'Month DD,YYYY') >= current_date - interval '5 years';



-- 7. Find all Movies and TV Shows directed by **Rajiv Chilaka**.
select title,director from netflix where director = 'Rajiv Chilaka';



-- 8. List all TV Shows with more than 5 seasons.
select title,duration from netflix where type = 'TV Show' and split_part(duration,' ',1)::int >= 5;



-- 9. Count the number of content items in each genre.
select 
count(show_id),
unnest(string_to_array(listed_in,',')) as genre from netflix group by genre;



-- 10. Find each year and the average number of content releases in India.
-- Return the top 5 years with the highest average content release.
select 
	extract(year from to_date(date_added,'Month DD, YYYY')) as year,
	count(*) as year_content,
	round(
	count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric*100,2 ) as avg
from netflix 
where country = 'India' group by 1 order by avg desc ; 



-- 11. List all movies that are documentaries.
SELECT
    title,
    listed_in
FROM netflix
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';



-- 12. Find all content without a director.
select 
title,director from netflix where Director is null ;


-- 13. Find how many movies **Salman Khan** appeared in during the last 10 years.
select 
	count(*) as total_number
from netflix 
where type = 'Movie' AND casts like '%Salman Khan%' 
AND to_date(date_added,'Month DD,YYYY') >= current_date - interval '10 years';



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
	unnest(string_to_array(casts,','))as actors,
	count(*) as total_content 
from netflix group by actors order by total_content desc limit 10 ;



-- 15. Categorize content as **Bad** if the description contains the keywords `kill` or `violence`, 
-- otherwise categorize it as **Good**, and count each category.
SELECT CATEGORY ,
COUNT(*) AS TOTAL FROM(select  
case when description ILIKE '%kill%'
          OR description ILIKE '%violence'
	then 'BAD'
	ELSE 'GOOD'
	END AS CATEGORY FROM NETFLIX) AS CATEGORISED 
	GROUP BY CATEGORY;



-- 16. Calculate the percentage of Netflix content that is Movies vs TV Shows.
select 
	type,
	count(*) as total_content,
	round(count(*):: numeric / (select count(*) from netflix)::numeric*100,2) 
	as percetage 
from netflix group by type ;



-- 17. Find the year in which Netflix added the most titles.
select extract(year from to_date(date_added,'Month DD, YYYY')) as year,
count(*) as total_content
from netflix group by year order by total_content desc limit 1;



--18. Find the percentage of Netflix titles that belong to each content rating.
select rating, 
round(count(*)::numeric/(select count(*) from netflix)::numeric*100,2) 
as percentage
from netflix group by rating order by percentage desc;


-- 19. Find the average number of titles released per year for each rating.
SELECT
    rating,
    ROUND(AVG(yearly_count), 2) AS avg_titles_per_year
FROM (
    SELECT
        rating,
        release_year,
        COUNT(*) AS yearly_count
    FROM netflix
    WHERE rating IS NOT NULL
    GROUP BY rating, release_year
) AS yearly_data
GROUP BY rating
ORDER BY avg_titles_per_year DESC;


-- 20. Find the countries that have produced the most Movies and TV Shows separately.
select type,unnest(string_to_array(country,',')) as country,
count(*) as data from netflix 
group by 1,2 order by data desc ;



-- 21. Find the average movie duration for each release year.
select release_year,round(avg(mins),2) as avg_duation from 
	(select release_year,split_part(duration,' ',1)::int as mins 
	from netflix 
	where type = 'Movie' and duration != 'null') 
as movie_mins
group by 1 order by 1  ;



-- 22. For each rating, find the number of Movies, TV Shows, and total titles.
select rating,type,count(*) as total_content from netflix group by 1,2;



-- 23. Find all movies that are longer than the average movie duration.
SELECT
    title,
    duration
FROM netflix
WHERE type = 'Movie'
  AND duration IS NOT NULL
  AND SPLIT_PART(duration, ' ', 1)::INT >
      (
          SELECT ROUND(AVG(SPLIT_PART(duration, ' ', 1)::INT),2)
          FROM netflix
          WHERE type = 'Movie'
            AND duration IS NOT NULL
      );



-- 24. Find the top 10 TV Shows with the highest number of seasons.
SELECT
    title,
    split_part(duration,' ',1)::int as no_of_ssns
FROM netflix
WHERE type = 'TV Show'
  AND duration IS NOT NULL 
  ORDER BY no_of_ssns DESC
	LIMIT 10;


-- 25. Find the top 10 countries with the greatest genre diversity..
SELECT
    distinct(TRIM(country)) AS country,
    COUNT(DISTINCT TRIM(genre)) AS genre_count
FROM (select 
     UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
     UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre from netflix)
	 where country is not null
	GROUP BY country
	ORDER BY genre_count DESC
	LIMIT 10;  



-- 26.  Find the release years where the number of TV Shows was greater than the number of Movies.
SELECT
    release_year,
    COUNT(CASE WHEN type = 'TV Show' THEN 1 END) AS tv_shows,
    COUNT(CASE WHEN type = 'Movie' THEN 1 END) AS movies
FROM netflix
GROUP BY release_year
HAVING COUNT(CASE WHEN type = 'TV Show' THEN 1 END)
     > COUNT(CASE WHEN type = 'Movie' THEN 1 END)
ORDER BY release_year;



-- 27. Find titles that were added to Netflix within one year of their original release.
select title from netflix 
where extract(year from to_date(date_added,'Month DD,YYYY')) - 
release_year <= 1 ;

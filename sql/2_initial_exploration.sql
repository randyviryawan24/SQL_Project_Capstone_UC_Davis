--Check whether there are duplicates in noc_regions table as a table reference
SELECT 
	COUNT(*) AS num_rows,
	COUNT (DISTINCT noc) AS num_noc
FROM noc_regions;


--initial exploration

-- Medals by country
SELECT
	n.region,
	COUNT (*) AS num_medals
	--RANK() OVER(ORDER BY COUNT (medal) DESC) AS rank_country,
	--ROUND(AVG(CAST(age AS REAL))) AS avg_age,
	--ROUND(AVG(height)) AS avg_height,
	--ROUND(AVG(weight)) AS avg_height
FROM athletes AS a
LEFT JOIN noc_regions AS n
	ON a.noc = n.noc
WHERE medal IS NOT NULL	
GROUP BY n.region
ORDER BY num_medals DESC;

--Number of competitions in each sport
WITH num_sport AS (
	SELECT
		sport,
		COUNT(DISTINCT event) AS num_competitions
	FROM athletes
	WHERE "year" BETWEEN 2000 AND 2016
	GROUP BY sport
	ORDER BY num_competitions DESC
),
total_competitions AS (
	SELECT SUM (num_competitions) AS total
	FROM num_sport
),
cumulative_sum AS (
SELECT
	n.sport,
	n.num_competitions,
	SUM(num_competitions) OVER (ORDER BY num_competitions DESC) AS cumulative_sum,
	t.total
FROM 
	num_sport AS n,
	total_competitions AS t
ORDER BY num_competitions DESC
)
SELECT 
	sport,
	num_competitions,
	cumulative_sum,
	(cumulative_sum/total*100) AS cumulative_percentage
FROM cumulative_sum;

--Age distribution of athletes
SELECT
	age,
	COUNT(DISTINCT id) AS num_athletes
FROM athletes
WHERE age IS NOT NULL
GROUP BY age
ORDER BY age ASC

--Weight and Height Distribution of each sport
SELECT
	sport,
	ROUND(AVG(height),2) AS avg_height,
	ROUND(AVG(weight),2) AS avg_weight
FROM athletes
WHERE 
	height IS NOT NULL AND 
	weight IS NOT NULL
GROUP BY sport
ORDER BY 
	avg_height DESC,
	avg_weight DESC

--Gender distribution of athletes of each sport
SELECT
	sport,
	COUNT(DISTINCT(CASE WHEN sex = 'M' THEN id END)) AS num_males,
	COUNT(DISTINCT(CASE WHEN sex = 'F' THEN id END)) AS num_females
FROM athletes
GROUP BY sport
ORDER BY 
	num_males DESC,
	num_females DESC 
;

--year and season medal distributions
SELECT
	"year",
	SUM(CASE WHEN season = 'Summer' THEN 1 ELSE 0 END) AS num_summer_games,
	SUM(CASE WHEN season = 'Winter' THEN 1 ELSE 0 END) AS num_winter_games
FROM athletes a 
GROUP BY "year"
ORDER BY "year";

-- the most competitions by sport in every year olympic
WITH rank_num_competitions_year AS (
SELECT
	"year",
	sport,
	COUNT(DISTINCT event) AS num_competitions,
	RANK () OVER(PARTITION BY "year" ORDER BY COUNT(DISTINCT event) DESC) AS rank_sport
FROM athletes
--WHERE "year" BETWEEN 2000 AND 2016
GROUP BY 
	sport,
	"year"
ORDER BY "year", num_competitions DESC
)
SELECT 
	"year",
	sport,
	num_competitions
FROM rank_num_competitions_year
WHERE rank_sport = 1 ;

SELECT
	"year",
	SUM(CASE WHEN season = 'Summer' THEN 1 ELSE 0 END) AS num_summer_games,
	SUM(CASE WHEN season = 'Winter' THEN 1 ELSE 0 END) AS num_winter_games
FROM athletes a 
GROUP BY "year"
ORDER BY "year";

SELECT*
FROM athletes a 
LIMIT 10



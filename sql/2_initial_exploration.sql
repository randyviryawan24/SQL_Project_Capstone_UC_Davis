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
SELECT
	sport,
	COUNT(DISTINCT event) AS num_competitions
FROM athletes	
GROUP BY sport
ORDER BY num_competitions DESC
LIMIT 5;

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
	season,
	COUNT(*) AS num_medals
FROM athletes
WHERE medal IS NOT NULL
GROUP BY 
	"year",
	season
ORDER BY num_medals DESC

SELECT
	MIN (year),
	MAX (year)
FROM athletes a 
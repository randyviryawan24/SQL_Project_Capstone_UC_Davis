--descriptive stats about participants
SELECT
	COUNT (*) AS total_data,
	COUNT (DISTINCT id) AS total_participants
FROM athletes 

--DISTINCT TEAM. Probably add to initial exploration later on (?)
SELECT DISTINCT team
FROM athletes;

-- Finding 1: there are 3 teams that don't have regions
-- Solution: 
SELECT
	DISTINCT a.team,
	a.noc,
	n.region
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE n.region IS NULL;
	
-- Following up from finding 1. Decided to add NOC and Regions for ROT, TUV and UNK. Especially for ROT and TUV as both are included in the analysis range based on sport event and year of olympics. As for unknown, it happened in 1912 olympics which beyond my scope of analysis
SELECT*
FROM athletes
WHERE 
	team = 'Refugee Olympic Athletes' OR
	team = 'Tuvalu' OR
	team = 'Unknown'
ORDER BY team
;
--Insert NOC and Regiosn for ROT, TUV and UNK
	
UPDATE noc_regions
SET region = 'Refugee Olyimpic Team'
WHERE noc = 'ROT';

UPDATE noc_regions
SET region = 'Tuvalu'
WHERE noc = 'TUV';

UPDATE noc_regions
SET region = 'Unknown'
WHERE noc = 'UNK';

-- Descriptive stats medals in athletics by country
WITH medals_athletics_by_country AS (
SELECT
	a."year",
	n.region,
	COUNT(*) AS num_medals
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.sport = 'Athletics' AND
	a.season = 'Summer'
GROUP BY
	a."year",
	n.region
ORDER BY
	a."year",
	num_medals DESC
)

SELECT
	m.region,
	SUM(m.num_medals) AS total_medals,
	ROUND(AVG(m.num_medals)) AS avg_medals,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_medals) AS median,
	MIN(m.num_medals ) AS min_medals,
	MAX(m.num_medals ) AS max_medals
FROM medals_athletics_by_country AS m
GROUP BY m.region
ORDER BY total_medals DESC
LIMIT 10
;
--Create View
CREATE VIEW medals_athletics_by_country AS
SELECT
	a."year",
	n.region,
	COUNT(*) AS num_medals
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.sport = 'Athletics' AND
	a.season = 'Summer'
GROUP BY
	a."year",
	n.region
ORDER BY
	a."year",
	num_medals DESC
;
-- Descriptive stats medals overall by country
CREATE VIEW medals_overall_by_country AS
SELECT
	a."year",
	n.region,
	COUNT(*) AS num_medals
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.season = 'Summer'
GROUP BY
	a."year",
	n.region
ORDER BY
	a."year",
	num_medals DESC
;
SELECT
	m.region,
	SUM(m.num_medals) AS total_medals,
	ROUND(AVG(m.num_medals)) AS avg_medals,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_medals) AS median,
	MIN(m.num_medals ) AS min_medals,
	MAX(m.num_medals ) AS max_medals
FROM medals_overall_by_country AS m
GROUP BY m.region
ORDER BY total_medals DESC
LIMIT 10
;


-- Descriptive stats medals in athletics by age range
CREATE VIEW medals_athletics_by_age_range AS
SELECT
	a."year",
	CASE 
		WHEN age <= 20 THEN '<= 20'
		WHEN age BETWEEN 21 AND 25 THEN '21 - 25'
		WHEN age BETWEEN 26 AND 30 THEN '26 - 30'
		WHEN age BETWEEN 31 AND 35 THEN '31 - 35'
		WHEN age BETWEEN 36 AND 40 THEN '36 - 40'
		ELSE '> 40'
	END AS age_range,
	COUNT(*) AS num_medals
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.sport = 'Athletics' AND
	a.season = 'Summer'
GROUP BY
	a."year",
	age_range
ORDER BY
	a."year",
	num_medals DESC
;
SELECT 
	age_range,
	SUM(num_medals) AS total_medals,
	ROUND(AVG(num_medals)) AS avg_medals,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_medals) AS median,
	MIN(num_medals ) AS min_medals,
	MAX(num_medals ) AS max_medals
FROM medals_athletics_by_age_range
GROUP BY
	age_range
ORDER BY 
	age_range;

-- Descriptive stats medals in athletics by bmi_range
CREATE VIEW medals_athletics_by_bmi_range AS
SELECT
	a."year",
	--ROUND(weight/(height/100)^2,2) AS bmi,
	CASE
		WHEN ROUND(weight/(height/100)^2,2) < 18.5 THEN 'Underweight'
		WHEN ROUND(weight/(height/100)^2,2) BETWEEN 18.5 AND 24.99 THEN 'Normal Weight'
		WHEN ROUND(weight/(height/100)^2,2) BETWEEN 25 AND 29.99 THEN 'Overweight'
		ELSE 'Obesity'
	END AS bmi_range,
	COUNT(*) AS num_medals
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.sport = 'Athletics' AND
	a.season = 'Summer'
GROUP BY
	a."year",
	--bmi,
	bmi_range;

SELECT
	bmi_range,
	SUM(num_medals) AS total_medals,
	ROUND(AVG(num_medals)) AS avg_medals,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_medals) AS median,
	MIN(num_medals ) AS min_medals,
	MAX(num_medals ) AS max_medals
FROM medals_athletics_by_bmi_range
GROUP BY 
	bmi_range


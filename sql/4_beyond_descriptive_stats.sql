-- Correlation between top 10 countries who won medals in athletics vs overall medals sporting events
CREATE VIEW top_10_medals_athletics_overall AS
SELECT
	n.region,
	SUM(CASE WHEN sport = 'Athletics' THEN 1 ELSE 0 END) AS medals_athletics,
	RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_overall_medals
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.season = 'Summer'
GROUP BY
	n.region
ORDER BY
	medals_athletics DESC
LIMIT 10
;
SELECT 
	'Top 10 medals athletics' AS name,
	corr(medals_athletics,rank_overall_medals) AS correlation_coefficient
FROM top_10_medals_athletics_overall



--Correlation between age vs medal status in athletics
CREATE VIEW age_medal_corr_athletics AS
SELECT
	age_range,
	CASE
		WHEN age_range = '<= 20' THEN 1
		WHEN age_range = '21 - 25' THEN 2
		WHEN age_range = '26 - 30' THEN 3
		WHEN age_range = '31 - 35' THEN 4
		ELSE 5
	END AS age_group,
	SUM(num_participants) AS num_medals
FROM medals_athletics_by_age_range
GROUP BY age_group,age_range
;

SELECT 
	'Athletics' AS sport,
	corr(age_group,num_medals) AS correlation_coefficient
FROM age_medal_corr_athletics

--Correlation between age vs medal status in overall sporting events
CREATE VIEW age_medal_corr_overall AS
SELECT
	age_range,
	CASE
		WHEN age_range = '<= 20' THEN 1
		WHEN age_range = '21 - 25' THEN 2
		WHEN age_range = '26 - 30' THEN 3
		WHEN age_range = '31 - 35' THEN 4
		WHEN age_range = '36 - 40' THEN 5
		ELSE 6
	END AS age_group,
	SUM(num_participants) AS num_medals
FROM medals_overall_by_age_range
GROUP BY age_group,age_range
ORDER BY age_group
;

SELECT 
	'overall sporting events' AS sport,
	corr(age_group,num_medals) AS correlation_coefficient
FROM age_medal_corr_overall

--UNION ALL
SELECT 
	'Athletics' AS sport,
	corr(age_group,num_medals) AS correlation_coefficient
FROM age_medal_corr_athletics
UNION ALL
SELECT 
	'overall sporting events' AS sport,
	corr(age_group,num_medals) AS correlation_coefficient
FROM age_medal_corr_overall



--Correlation between age vs medal status in each sporting events
CREATE OR REPLACE VIEW age_medal_corr_each AS
SELECT
	sport,
	age_range,
	CASE
		WHEN age_range = '<= 20' THEN 1
		WHEN age_range = '21 - 25' THEN 2
		WHEN age_range = '26 - 30' THEN 3
		WHEN age_range = '31 - 35' THEN 4
		WHEN age_range = '36 - 40' THEN 5
		ELSE 6
	END AS age_group,
	SUM(num_participants) AS num_medals
FROM (
	SELECT
		a."year",
		a.sport,
		CASE 
			WHEN age <= 20 THEN '<= 20'
			WHEN age BETWEEN 21 AND 25 THEN '21 - 25'
			WHEN age BETWEEN 26 AND 30 THEN '26 - 30'
			WHEN age BETWEEN 31 AND 35 THEN '31 - 35'
			WHEN age BETWEEN 36 AND 40 THEN '36 - 40'
			ELSE '> 40'
		END AS age_range,
		COUNT(DISTINCT id) AS num_participants
	FROM athletes a
	LEFT JOIN noc_regions n
		ON a.noc = n.noc
	WHERE 
		a.medal IS NOT NULL AND
		(a."year" BETWEEN 2000 AND 2016) AND
		a.season = 'Summer'
	GROUP BY
		a."year",
		a.sport,
		age_range
	ORDER BY
		a."year",
		a.sport,
		num_participants DESC
)
GROUP BY sport,age_group,age_range
ORDER BY sport,age_group
;

SELECT 
	sport,
	corr(age_group,num_medals) AS correlation_coefficient
FROM age_medal_corr_each
GROUP BY sport
ORDER BY correlation_coefficient

--Correlation between BMI vs medal status in athletics
CREATE VIEW bmi_medal_corr_athletics AS
SELECT 
	bmi_range,
	CASE
		WHEN bmi_range = 'Underweight' THEN 1
		WHEN bmi_range = 'Normal Weight' THEN 2
		WHEN bmi_range = 'Overweight' THEN 3
		WHEN bmi_range = 'Obesity' THEN 4
	END AS bmi_group,
	SUM(num_participants) AS num_medals
FROM medals_athletics_by_bmi_range
GROUP BY bmi_range
ORDER BY bmi_group
;
SELECT 
	corr(bmi_group,num_medals)
FROM bmi_medal_corr_athletics

--Correlation between BMI vs medal status in overall sporting events
CREATE VIEW bmi_medal_corr_overall AS
SELECT 
	bmi_range,
	CASE
		WHEN bmi_range = 'Underweight' THEN 1
		WHEN bmi_range = 'Normal Weight' THEN 2
		WHEN bmi_range = 'Overweight' THEN 3
		WHEN bmi_range = 'Obesity' THEN 4
	END AS bmi_group,
	SUM(num_participants) AS num_medals
FROM medals_overall_by_bmi_range
GROUP BY bmi_range
ORDER BY bmi_group
;
SELECT 
	corr(bmi_group,num_medals)
FROM bmi_medal_corr_overall


--UNION ALL
SELECT 
	'Athletics' AS sport,
	corr(bmi_group,num_medals) AS correlation_coefficient
FROM bmi_medal_corr_athletics
UNION ALL
SELECT 
	'overall sporting events' AS sport,
	corr(bmi_group,num_medals) AS correlation_coefficient
FROM bmi_medal_corr_overall




--Correlation between age vs medal status in each sporting events
CREATE VIEW bmi_medal_corr_each AS
SELECT
	sport,
	bmi_range,
	CASE
		WHEN bmi_range = 'Underweight' THEN 1
		WHEN bmi_range = 'Normal Weight' THEN 2
		WHEN bmi_range = 'Overweight' THEN 3
		WHEN bmi_range = 'Obesity' THEN 4
	END AS bmi_group,
	SUM(num_participants) AS num_medals
FROM (SELECT
	a.sport,
	a."year",
	--ROUND(weight/(height/100)^2,2) AS bmi,
	CASE
		WHEN ROUND(weight/(height/100)^2,2) < 18.5 THEN 'Underweight'
		WHEN ROUND(weight/(height/100)^2,2) BETWEEN 18.5 AND 24.99 THEN 'Normal Weight'
		WHEN ROUND(weight/(height/100)^2,2) BETWEEN 25 AND 29.99 THEN 'Overweight'
		ELSE 'Obesity'
	END AS bmi_range,
	COUNT(DISTINCT id) AS num_participants
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.season = 'Summer'
GROUP BY
	a."year",
	a.sport,
	bmi_range
)
--WHERE sport IN ('Modern Pentathlon','Triathlon','Tennis')
GROUP BY
	sport,
	bmi_range,
	bmi_group
ORDER BY
	sport,
	bmi_group
;


SELECT
	sport,
	corr(bmi_group,num_medals) AS correlation_coefficient -- 'Modern Pentathlon and Triathlon IS NULL because they both only contain one bmi_group
FROM bmi_medal_corr_each
GROUP BY sport
ORDER BY correlation_coefficient

	
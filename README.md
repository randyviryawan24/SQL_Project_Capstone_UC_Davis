# Proposal Preparation
## 1. Dataset Descripition
I decided to pick **Olympic Games results from 1896 to 2016** as my dataset since I have a profound interest in sports and would like to explore one of the biggest sporting events across the world.

## 2. Importing and Cleaning the Data
### Creating Tables
```sql
CREATE TABLE noc_regions (
	NOC TEXT PRIMARY KEY,
	region TEXT,
	notes TEXT
);
CREATE TABLE athletes (
	ID SERIAL PRIMARY KEY,
	Name TEXT,
	Sex TEXT,
	Age INT,
	Height REAL,
	Weight REAL,
	Team TEXT,
	NOC TEXT,
	Games TEXT,
	YEAR INT,
	Season TEXT,
	City TEXT,
	Sport TEXT,
	EVENT TEXT,
	Medal TEXT,
	FOREIGN KEY (NOC) REFERENCES noc_regions (NOC)
);
```
### Cleaning Data
```sql
--Adjust the columns name to be lowercase
ALTER TABLE athletes RENAME COLUMN "ID" TO id;
ALTER TABLE athletes RENAME COLUMN "Name" TO name;
ALTER TABLE athletes RENAME COLUMN "Sex" TO sex;
ALTER TABLE athletes RENAME COLUMN "Age" TO age;
ALTER TABLE athletes RENAME COLUMN "Height" TO height;
ALTER TABLE athletes RENAME COLUMN "Weight" TO weight;
ALTER TABLE athletes RENAME COLUMN "Team" TO team;
ALTER TABLE athletes RENAME COLUMN "NOC" TO noc;
ALTER TABLE athletes RENAME COLUMN "Games" TO games;
ALTER TABLE athletes RENAME COLUMN "YEAR" TO year;
ALTER TABLE athletes RENAME COLUMN "Season" TO season;
ALTER TABLE athletes RENAME COLUMN "City" TO city;
ALTER TABLE athletes RENAME COLUMN "Sport" TO sport;
ALTER TABLE athletes RENAME COLUMN "EVENT" TO event;
ALTER TABLE athletes RENAME COLUMN "Medal" TO medal;
ALTER TABLE noc_regions RENAME COLUMN "NOC" TO noc;
```
```sql
--Drop the primary key in ID since one athlete can participate in multiple competitions within the same sporting event
SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'athletes' AND constraint_type = 'PRIMARY KEY';

ALTER TABLE athletes
DROP CONSTRAINT athletes_pkey;
```
```sql
--Update SIN to SGP in noc_regions following athletes table
UPDATE noc_regions
SET noc = 'SGP'
WHERE noc = 'SIN';
```
### Importing Data
```sql
-- Insert data into tables while treating 'NA' values AS 'NULL'
\copy athletes(id, name, sex, age, height, weight, team, noc, games, year, season, city, sport, event, medal) 
FROM 'C:/Users/Randy V/Downloads/SportsStats/athlete_events.csv' 
DELIMITER ',' 
CSV HEADER 
NULL 'NA';

\copy noc_regions(noc, region, notes) 
FROM 'C:/Users/Randy V/Downloads/SportsStats/noc_regions.csv' 
DELIMITER ',' 
CSV HEADER 
NULL 'NA';
```
## 3. Initial Exploration Data
### Medals by country
```sql
SELECT
	n.region,
	COUNT (*) AS num_medals
FROM athletes AS a
LEFT JOIN noc_regions AS n
	ON a.noc = n.noc
WHERE medal IS NOT NULL	
GROUP BY n.region
ORDER BY num_medals DESC;
```
![The top medal-winning country](docs/top_5_regions_medals.png)
*Bar Chart is limited by 5 due to visualization limitation issues*

### Number of competitions in each sport throughout the whole olympic events
```sql
SELECT
	sport,
	COUNT(DISTINCT event) AS num_competitions
FROM athletes	
GROUP BY sport
ORDER BY num_competitions DESC;
```
![The most popular sport](docs/top_5_num_competitions.png)
*Bar Chart is limited by 5 due to visualization limitation issues*

### Most competition by sport across olympic years
```sql
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
```
| Year | Sport               | Num Competitions |
|------|---------------------|------------------|
| 1896 | Athletics           | 12               |
| 1900 | Athletics           | 23               |
| 1904 | Athletics           | 24               |
| 1906 | Athletics           | 21               |
| 1908 | Athletics           | 26               |
| 1912 | Athletics           | 30               |
| 1920 | Athletics           | 29               |
| 1924 | Athletics           | 27               |
| 1928 | Athletics           | 27               |
| 1932 | Athletics           | 29               |
| 1936 | Athletics           | 29               |
| 1948 | Athletics           | 33               |
| 1952 | Athletics           | 33               |
| 1956 | Athletics           | 33               |
| 1960 | Athletics           | 34               |
| 1964 | Athletics           | 36               |
| 1968 | Athletics           | 36               |
| 1972 | Athletics           | 38               |
| 1976 | Athletics           | 37               |
| 1980 | Athletics           | 38               |
| 1984 | Athletics           | 41               |
| 1988 | Athletics           | 42               |
| 1992 | Athletics           | 43               |
| 1994 | Cross Country Skiing| 10               |
| 1994 | Alpine Skiing       | 10               |
| 1994 | Speed Skating       | 10               |
| 1996 | Athletics           | 44               |
| 1998 | Alpine Skiing       | 10               |
| 1998 | Cross Country Skiing| 10               |
| 1998 | Speed Skating       | 10               |
| 2000 | Athletics           | 46               |
| 2002 | Cross Country Skiing| 12               |
| 2004 | Athletics           | 46               |
| 2006 | Speed Skating       | 12               |
| 2006 | Cross Country Skiing| 12               |
| 2008 | Athletics           | 47               |
| 2010 | Speed Skating       | 12               |
| 2010 | Cross Country Skiing| 12               |
| 2012 | Athletics           | 47               |
| 2014 | Cross Country Skiing| 12               |
| 2014 | Speed Skating       | 12               |
| 2016 | Athletics           | 47               |

### Age distribution of athletes
```sql
SELECT
	age,
	COUNT(DISTINCT id) AS num_athletes
FROM athletes
GROUP BY age
ORDER BY age ASC
```
![distribution_athletes_by_age](docs/distribution_by_age.png)

### Weight and Height Distribution of each sport
```sql
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
```
| **Sport**               | **Avg Height (cm)** | **Avg Weight (kg)** |
|-------------------------|---------------------|---------------------|
| Basketball              | 191.21              | 85.78               |
| Volleyball              | 186.98              | 78.90               |
| Beach Volleyball        | 186.20              | 79.09               |
| Water Polo              | 185.03              | 84.57               |
| Rowing                  | 184.26              | 80.17               |
| Handball                | 183.41              | 81.50               |
| Tug-Of-War              | 182.73              | 91.64               |
| Baseball                | 182.60              | 85.72               |
| Bobsleigh               | 181.60              | 89.15               |
| Motorboating            | 181.00              | 77.00               |
| Ice Hockey              | 178.92              | 80.84               |
| Tennis                  | 178.92              | 70.80               |
| Swimming                | 178.59              | 70.59               |
| Canoeing                | 178.55              | 76.49               |
| Sailing                 | 178.26              | 75.97               |
| Modern Pentathlon       | 178.10              | 70.28               |
| Fencing                 | 177.30              | 71.39               |
| Taekwondo               | 176.75              | 68.09               |
| Luge                    | 176.66              | 77.28               |
| Nordic Combined         | 176.52              | 66.91               |
| Ski Jumping             | 176.49              | 65.08               |
| Athletics               | 176.26              | 69.25               |
| Skeleton                | 176.22              | 74.17               |
| Cycling                 | 176.16              | 70.07               |
| Football                | 175.39              | 70.45               |
| Rugby Sevens            | 175.36              | 79.01               |
| Equestrianism           | 174.40              | 67.80               |
| Badminton               | 174.22              | 68.17               |
| Curling                 | 174.17              | 72.13               |
| Judo                    | 174.16              | 78.78               |
| Speed Skating           | 174.10              | 70.03               |
| Golf                    | 174.05              | 71.19               |
| Biathlon                | 174.05              | 66.63               |
| Lacrosse                | 174.00              | 66.50               |
| Rugby                   | 173.67              | 77.53               |
| Triathlon               | 173.64              | 61.82               |
| Shooting                | 173.53              | 74.03               |
| Alpine Skiing           | 173.52              | 72.08               |
| Hockey                  | 173.39              | 69.16               |
| Cross Country Skiing    | 173.26              | 65.88               |
| Archery                 | 173.25              | 70.01               |
| Snowboarding            | 173.04              | 69.53               |
| Art Competitions        | 172.82              | 74.61               |
| Boxing                  | 172.79              | 65.24               |
| Wrestling               | 172.39              | 75.51               |
| Table Tennis            | 171.25              | 64.92               |
| Freestyle Skiing        | 170.94              | 67.03               |
| Short Track Speed Skating| 170.11             | 64.31               |
| Softball                | 169.43              | 67.47               |
| Synchronized Swimming   | 168.49              | 55.86               |
| Figure Skating          | 168.15              | 59.54               |
| Weightlifting           | 167.82              | 79.55               |
| Rhythmic Gymnastics     | 167.80              | 48.76               |
| Diving                  | 166.66              | 60.58               |
| Trampolining            | 166.56              | 59.32               |
| Gymnastics              | 162.88              | 56.91               |

### Gender distribution of athletes of each sport
```sql
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
```
| **Sport**                | **Num Males** | **Num Females** |
|--------------------------|---------------|-----------------|
| Athletics                | 15542         | 6529            |
| Rowing                   | 6204          | 1483            |
| Football                 | 5427          | 734             |
| Boxing                   | 5197          | 65              |
| Swimming                 | 5144          | 3621            |
| Cycling                  | 5105          | 714             |
| Wrestling                | 4766          | 222             |
| Shooting                 | 4145          | 737             |
| Sailing                  | 3851          | 629             |
| Ice Hockey               | 3386          | 498             |
| Fencing                  | 3243          | 880             |
| Hockey                   | 2829          | 996             |
| Gymnastics               | 2635          | 1499            |
| Weightlifting            | 2526          | 356             |
| Canoeing                 | 2504          | 702             |
| Basketball               | 2481          | 932             |
| Water Polo               | 2262          | 337             |
| Judo                     | 1967          | 757             |
| Equestrianism            | 1886          | 459             |
| Alpine Skiing            | 1739          | 996             |
| Cross Country Skiing     | 1683          | 717             |
| Handball                 | 1675          | 1027            |
| Art Competitions         | 1610          | 204             |
| Bobsleigh                | 1585          | 109             |
| Volleyball               | 1374          | 1129            |
| Speed Skating            | 1054          | 528             |
| Ski Jumping              | 844           | 30              |
| Diving                   | 831           | 635             |
| Biathlon                 | 764           | 371             |
| Baseball                 | 761           | 0               |
| Tennis                   | 760           | 486             |
| Modern Pentathlon        | 750           | 114             |
| Figure Skating           | 748           | 824             |
| Archery                  | 613           | 500             |
| Nordic Combined          | 605           | 0               |
| Luge                     | 544           | 228             |
| Badminton                | 399           | 412             |
| Table Tennis             | 372           | 377             |
| Freestyle Skiing         | 359           | 267             |
| Snowboarding             | 328           | 239             |
| Taekwondo                | 241           | 229             |
| Short Track Speed Skating| 235           | 209             |
| Beach Volleyball         | 194           | 189             |
| Curling                  | 186           | 160             |
| Triathlon                | 180           | 175             |
| Tug-Of-War               | 160           | 0               |
| Rugby                    | 155           | 0               |
| Rugby Sevens             | 151           | 148             |
| Golf                     | 148           | 70              |
| Skeleton                 | 101           | 45              |
| Polo                     | 87            | 0               |
| Lacrosse                 | 60            | 0               |
| Trampolining             | 49            | 44              |
| Alpinism                 | 24            | 1               |
| Cricket                  | 24            | 0               |
| Military Ski Patrol      | 24            | 0               |
| Motorboating             | 13            | 1               |
| Jeu De Paume             | 11            | 0               |
| Croquet                  | 7             | 3               |
| Racquets                 | 7             | 0               |
| Roque                    | 4             | 0               |
| Basque Pelota            | 2             | 0               |
| Aeronautics              | 1             | 0               |
| Rhythmic Gymnastics      | 0             | 567             |
| Synchronized Swimming    | 0             | 550             |
| Softball                 | 0             | 367             |

### Year and season medal distributions
```sql
SELECT
	"year",
	SUM(CASE WHEN season = 'Summer' THEN 1 ELSE 0 END) AS num_summer_games,
	SUM(CASE WHEN season = 'Winter' THEN 1 ELSE 0 END) AS num_winter_games
FROM athletes a 
GROUP BY "year"
ORDER BY "year";
```
| Year | Num Summer Games | Num Winter Games |
|------|------------------|------------------|
| 1896 | 380              | 0                |
| 1900 | 1936             | 0                |
| 1904 | 1301             | 0                |
| 1906 | 1733             | 0                |
| 1908 | 3101             | 0                |
| 1912 | 4040             | 0                |
| 1920 | 4292             | 0                |
| 1924 | 5233             | 460              |
| 1928 | 4992             | 582              |
| 1932 | 2969             | 352              |
| 1936 | 6506             | 895              |
| 1948 | 6405             | 1075             |
| 1952 | 8270             | 1088             |
| 1956 | 5127             | 1307             |
| 1960 | 8119             | 1116             |
| 1964 | 7702             | 1778             |
| 1968 | 8588             | 1891             |
| 1972 | 10304            | 1655             |
| 1976 | 8641             | 1861             |
| 1980 | 7191             | 1746             |
| 1984 | 9454             | 2134             |
| 1988 | 12037            | 2639             |
| 1992 | 12977            | 3436             |
| 1994 | 0                | 3160             |
| 1996 | 13780            | 0                |
| 1998 | 0                | 3605             |
| 2000 | 13821            | 0                |
| 2002 | 0                | 4109             |
| 2004 | 13443            | 0                |
| 2006 | 0                | 4382             |
| 2008 | 13602            | 0                |
| 2010 | 0                | 4402             |
| 2012 | 12920            | 0                |
| 2014 | 0                | 4891             |
| 2016 | 13688            | 0                |


## 4. ERD
![ERD](docs/ERD.png)
# Project Proposal
## 1. Description
Welcome to my **SQL Portfolio Project**, where I analyze **Olympic Games results from 1896 to 2016**. This project serves as a deep dive into historical trends and insights from the Games, with the goal of **providing valuable data-driven strategies for countries to better plan for future Olympic events**. Through this exploration, I aim to **uncover patterns and trends** that could help inform decision-making and strategic planning for nations looking to improve their performance in upcoming competitions.
## 2. Questions
- What is the correlation between sports with a high number of competitions and a country's success in winning Olympic medals?

	*The goal is to identify sports with many competitions and explore their impact on a country’s medal achievements in the Olympics.*

- How does age influence an athlete's chances of winning medals?

	*The aim is to determine if there is a specific age range where athletes are more likely to win medals.*

- How does Body Mass Index (BMI) — calculated from weight and height — influence an athlete’s chances of winning medals?

	*The focus is on discovering if certain physical attributes, measured through BMI, correlate with higher chances of winning medals.*

## 3. Hypotheses
- Sports that provide **the most competitions** will have a positive impact on overall medal achievements in the Olympics.
- Athletes between **the ages of 26 and 30** tend to win more medals compared to other age groups.
- Athletes with a **BMI in the normal weight range (18.5 - 24.9)** tend to win more medals compared to those in other BMI categories.

## 4. Approach
- The analysis will focus on Olympic data **from 2000 onwards**, as it is more relevant for future planning.
- The study will be centered on the **Summer Olympics**, as it hosts a greater number of events compared to the Winter Olympics.
- **Athletics** will be the primary sport analyzed, as it consistently has the most competitions across Olympic events.
- **Age** will be grouped into categories for easier analysis.
- **BMI** will be used to measure physical attributes (height and weight).

## 5. Descriptive Statistic

### 1. Total medals and participants
```sql
SELECT
	"year",
	COUNT (*) AS total_medals,
	COUNT (DISTINCT id) AS total_participants
FROM athletes
WHERE 
	medal IS NOT NULL AND
	("year" BETWEEN 2000 AND 2016) AND
	sport = 'Athletics' AND
	season = 'Summer'
GROUP BY 
	"year"
ORDER BY
	"year"
; 
```
| Year | Total Medals | Total Participants |
|------|-------------|--------------------|
| 2000 | 190         | 177                |
| 2004 | 180         | 166                |
| 2008 | 187         | 170                |
| 2012 | 190         | 171                |
| 2016 | 192         | 174                |

**Summary:**
- This statistic is used to understand the data in general specifically because there are multiple *id* within the data

**Key Points:**
- The number of total participants is lesser than the total medals meaning that one participant can possibly participate and win medals in multiple sport events in athletics
- The total medals and winners in athletics over 2000 to 2016 slightly change every year.
### 2. Top 10 medals by country in athletics vs overall
#### Top 10 medals in athletics by country
```sql
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

SELECT
	m.region,
	SUM(m.num_medals) AS total_medals,
	ROUND(AVG(m.num_medals)) AS avg_medals,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_medals) AS median_medals,
	MIN(m.num_medals ) AS min_medals,
	MAX(m.num_medals ) AS max_medals
FROM medals_athletics_by_country AS m
GROUP BY m.region
ORDER BY total_medals DESC
LIMIT 10
```
#### Top 10 medals overall by country

```sql
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
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_medals) AS median_medals,
	MIN(m.num_medals ) AS min_medals,
	MAX(m.num_medals ) AS max_medals
FROM medals_overall_by_country AS m
GROUP BY m.region
ORDER BY total_medals DESC
LIMIT 10
;
```
#### Visualization Top 10 medals athletics by country
| Region   | Total Medals | Avg Medals | Median Medals | Min Medals | Max Medals |
|----------|-------------|------------|---------------|------------|------------|
| USA      | 186         | 37         | 38            | 28         | 46         |
| Jamaica  | 105         | 21         | 23            | 13         | 30         |
| Russia   | 93          | 23         | 23            | 18         | 27         |
| Kenya    | 53          | 11         | 11            | 7          | 15         |
| UK       | 41          | 8          | 7             | 6          | 14         |
| Ethiopia | 37          | 7          | 7             | 7          | 8          |
| Bahamas  | 30          | 6          | 6             | 2          | 11         |
| Cuba     | 22          | 4          | 5             | 1          | 9          |
| Nigeria  | 21          | 7          | 7             | 6          | 8          |
| France   | 19          | 5          | 5             | 2          | 6          |


#### Visualization Top 10 medals overall by country
| Region      | Total Medals | Avg Medals | Median Medals | Min Medals | Max Medals |
|------------|-------------|------------|---------------|------------|------------|
| USA        | 1334        | 267        | 263           | 242        | 317        |
| Russia     | 773         | 155        | 142           | 115        | 189        |
| Australia  | 685         | 137        | 149           | 82         | 183        |
| Germany    | 619         | 124        | 118           | 94         | 159        |
| China      | 598         | 120        | 113           | 79         | 184        |
| UK         | 463         | 93         | 81            | 54         | 145        |
| France     | 374         | 75         | 77            | 53         | 96         |
| Italy      | 351         | 70         | 68            | 42         | 104        |
| Japan      | 336         | 67         | 64            | 44         | 93         |
| Netherlands| 333         | 67         | 69            | 47         | 79         |


#### Visualization total medals **athletics** by year and country
![medals_athletics_year_region](docs/medals_athletics_year_region.png)

#### Visualization total medals **overall** by year and country
![medals_overall_year_region](docs/medals_overall_year_region.png)

**Summary:**  
The goal of this **descriptive statistic** is to analyze the **correlation** between a country's **performance** in **athletics** and its overall **Olympic** success from **2000 to 2016**.  

**Key Points:**  

- The **USA** consistently dominates in both **athletics** and total **Olympic medals**.  
- Five nations—**USA, Russia, UK, France, and Germany**—rank in the **Top 10** for both **athletics** and overall **Olympic** medal counts.  
- In **2016**, **Russia** was banned from competing in **athletics** due to allegations of a **state-sponsored doping program**.  
- Between **2000 and 2016**, **USA, UK, Jamaica, and Kenya** showed an upward trend in **athletics medals**, while **Russia and Nigeria** experienced the most significant decline.  
- In terms of **overall Olympic performance**, **UK** demonstrated the most notable **growth** over this period.  


### 3. Winners by age range in athletics vs overall sports
####  Winners by age range in athletics
```sql 
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
	COUNT(DISTINCT id) AS num_participants
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
	num_participants DESC
;
SELECT 
	age_range,
	SUM(num_participants) AS total_participants,
	ROUND(AVG(num_participants)) AS avg_participants,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_participants) AS median_participants,
	MIN(num_participants ) AS min_participants,
	MAX(num_participants ) AS max_participants
FROM medals_athletics_by_age_range
GROUP BY
	age_range
ORDER BY 
	age_range;

```
####  Winners by age range in overall sports
```sql
CREATE VIEW medals_overall_by_age_range AS
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
	age_range
ORDER BY
	a."year",
	num_participants DESC
;
SELECT 
	age_range,
	SUM(num_participants) AS total_participants,
	ROUND(AVG(num_participants)) AS avg_participants,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_participants) AS median_participants,
	MIN(num_participants ) AS min_participants,
	MAX(num_participants ) AS max_participants
FROM medals_overall_by_age_range
GROUP BY
	age_range
ORDER BY 
	age_range;
```
####  Visualization Winners by age range in athletics
| Age Range  | Total Participants | Avg Participants | Median Participants | Min Participants | Max Participants |
|------------|-------------------|------------------|----------------------|------------------|------------------|
| <= 20      | 59                | 12               | 12                   | 8                | 15               |
| 21 - 25    | 352               | 70               | 69                   | 63               | 84               |
| 26 - 30    | 323               | 65               | 62                   | 58               | 78               |
| 31 - 35    | 105               | 21               | 24                   | 10               | 29               |
| 36 - 40    | 19                | 4                | 4                    | 1                | 7                |

####  Visualization Winners by age range in overall sports
| Age Range  | Total Participants | Avg Participants | Median Participants | Min Participants | Max Participants |
|------------|-------------------|------------------|----------------------|------------------|------------------|
| <= 20      | 886               | 177              | 176                  | 165              | 195              |
| 21 - 25    | 3,499             | 700              | 687                  | 683              | 743              |
| 26 - 30    | 3,200             | 640              | 633                  | 615              | 660              |
| 31 - 35    | 1,172             | 234              | 230                  | 211              | 259              |
| 36 - 40    | 285               | 57               | 55                   | 50               | 66               |
| > 40       | 133               | 27               | 27                   | 23               | 29               |

#### Visualization Winner by age range and year in **athletics** 
![pic](docs/participants_athletics_by_age_range.png)

#### Visualization Winner by age range and year in **overall sports** 
![pic](docs/participants_overall_by_age_range.png)

#### Winners Age distribution in **athletics**
```sql
CREATE VIEW medals_athletics_by_age AS
SELECT
	a.age,
	COUNT(DISTINCT id) AS num_participants
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.sport = 'Athletics' AND
	a.season = 'Summer'	
GROUP BY 
	a.age;
```
#### Winners Age distribution in **overall sports**
```sql
CREATE VIEW medals_overall_by_age AS
SELECT
	a.age,
	COUNT(DISTINCT id) AS num_participants
FROM athletes a
LEFT JOIN noc_regions n
	ON a.noc = n.noc
WHERE 
	a.medal IS NOT NULL AND
	(a."year" BETWEEN 2000 AND 2016) AND
	a.season = 'Summer'	
GROUP BY 
	a.age;
	
```
#### Visualization Winners Age distribution in **athletics**
![pic](docs/participants_athletics_by_age.png)
#### Visualization Winners Age distribution in **overall sports**
![pic](docs/participants_overall_by_age.png)
**Summary:**  
This **descriptive statistic** aims to identify the **age ranges** that dominate **Olympic winners** in both **athletics** and overall **sporting events** from **2000 to 2016**.  

**Key Points:**  

- The **21 - 25** age group has won the most **Olympic medals**, with a slight lead over the **26 - 30** age group. Together, these two age ranges account for over **70%** of medal wins in both **athletics** and overall **sporting events**.  
- **Age 26** stands out as the most common age among **Olympic medal winners** in both **athletics** and overall **sporting events**.  

### 4. Winners by BMI range in athletics vs overall
####  Winners by BMI range in **athletics**
```sql
CREATE VIEW medals_athletics_by_bmi_range AS
SELECT
	a."year",
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
	a.sport = 'Athletics' AND
	a.season = 'Summer'
GROUP BY
	a."year",
	--bmi,
	bmi_range;

SELECT
	bmi_range,
	SUM(num_participants) AS total_participants,
	ROUND(AVG(num_participants)) AS avg_participants,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_participants) AS median_participants,
	MIN(num_participants ) AS min_participants,
	MAX(num_participants ) AS max_participants
FROM medals_athletics_by_bmi_range
GROUP BY 
	bmi_range
```
| BMI Range      | Total Participants | Avg Participants | Median Participants | Min Participants | Max Participants |
|---------------|-------------------|------------------|----------------------|------------------|------------------|
| Normal Weight | 621               | 124              | 122                  | 120              | 131              |
| Obesity       | 58                | 12               | 10                   | 8                | 16               |
| Overweight    | 91                | 18               | 18                   | 15               | 22               |
| Underweight   | 88                | 18               | 18                   | 14               | 21               |

####  Winners by BMI range in **overall sports**
```sql
CREATE VIEW medals_overall_by_bmi_range AS
SELECT
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
	--bmi,
	bmi_range;

SELECT
	bmi_range,
	SUM(num_participants) AS total_participants,
	ROUND(AVG(num_participants)) AS avg_participants,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY num_participants) AS median_participants,
	MIN(num_participants ) AS min_participants,
	MAX(num_participants ) AS max_participants
FROM medals_overall_by_bmi_range
GROUP BY 
	bmi_range
```
| BMI Range      | Total Participants | Avg Participants | Median Participants | Min Participants | Max Participants |
|---------------|-------------------|------------------|----------------------|------------------|------------------|
| Normal Weight | 6,797             | 1,359            | 1,369                | 1,315            | 1,385            |
| Obesity       | 317               | 63               | 65                   | 49               | 74               |
| Overweight    | 1,696             | 339              | 331                  | 315              | 375              |
| Underweight   | 365               | 73               | 74                   | 66               | 79               |

####  Visualization Winners by BMI range and year in **athletics**
![pic](docs/participants_athletics_by_bmi_range.png)
####  Visualization Winners by BMI range and year in **overall sports**
![pic](docs/participants_overall_by_bmi_range.png)
**Summary:**  
This **descriptive statistic** examines which **BMI ranges** dominate among **Olympic winners** in both **athletics** and overall **sporting events** from **2000 to 2016**.  

**Key Points:**  

- **Normal Weight** athletes dominate **Olympic medals** in both **athletics** and overall **sporting events**, with over **70% probability** of winning.  
- Interestingly, in overall **sporting events**, **Overweight** athletes secure **17% to 20% chances of winning medals**, while in **athletics**, the proportion is more evenly distributed between **Overweight** and **Underweight** athletes.  

## 6. Hypotheses Analysis  

### *Initial Hypothesis*  
- Sports that offer **the most competitions** positively impact a country's overall **Olympic medal achievements**.  

### *Result*  
- Analysis suggests that **athletics** does influence medal success, as **5 out of 10 countries** in the **top athletics medal rankings** also appear in the **top 10 overall sporting events medal rankings**. However, this impact is not overwhelmingly strong. Only **the United States and Russia (excluding 2016 data)** show a clear correlation between dominance in **athletics** and overall **sporting events**. While **UK, France, and Germany** rank in the **top 10 for both**, their **athletics** performance is surpassed by **Jamaica and Kenya**, which are not in the **top 10 for overall sporting events**.  

### *Initial Hypothesis*  
- Athletes between **the ages of 26 and 30** are more likely to win medals than those in other age groups.  

### *Result*  
- The **21 - 25** age group wins the most **Olympic medals** in both **athletics** and overall **sporting events**, slightly ahead of the **26 - 30** age group.  

### *Initial Hypothesis*  
- Athletes with a **BMI in the normal weight range (18.5 - 24.9)** are more likely to win medals compared to other BMI categories.  

### *Result*  
- **Normal Weight** athletes overwhelmingly dominate medal wins, accounting for **over 70%** of total victories across all categories.  

### *Additional Questions to Answer*
-  What is the distribution of medal dominance across different sporting events within the top 10 Olympic medalists?
- How does BMI distribution vary across different sporting events? Are certain sports more dominated by Overweight or Underweight athletes?
- Do athletes in the 21 - 25 age range dominate specific sports, or is their success evenly distributed across all sporting events?
- How do the top 10 medal-winning countries compare in terms of age range and BMI trends?
- Are there outliers—athletes who don’t fit the typical age or BMI range—who have still achieved significant success?
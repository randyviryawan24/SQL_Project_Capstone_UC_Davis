# Proposal Preparation
## 1. Dataset Descripition
Welcome to my **SQL Portfolio Project**, where I analyze **Olympic Games results from 1896 to 2016**. This project serves as a deep dive into historical trends and insights from the Games, with the goal of **providing valuable data-driven strategies for countries to better plan for future Olympic events**. Through this exploration, I aim to **uncover patterns and trends** that could help inform decision-making and strategic planning for nations looking to improve their performance in upcoming competitions.


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

### Number of competitions in each sport
```sql
SELECT
	sport,
	COUNT(DISTINCT event) AS num_competitions
FROM athletes	
GROUP BY sport
ORDER BY num_competitions DESC;
```
![The most popular sport](docs\top_5_num_competitions.png)
*Bar Chart is limited by 5 due to visualization limitation issues*

### Age distribution of athletes
```sql
SELECT
	age,
	COUNT(DISTINCT id) AS num_athletes
FROM athletes
GROUP BY age
ORDER BY age ASC
```
![distribution_athletes_by_age](docs\distribution_by_age.png)

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
	season,
	COUNT(*) AS num_medals
FROM athletes
WHERE medal IS NOT NULL
GROUP BY 
	"year",
	season
ORDER BY num_medals DESC
```
| **Year** | **Season** | **Num Medals** |
|----------|------------|----------------|
| 2008     | Summer     | 2048           |
| 2016     | Summer     | 2023           |
| 2000     | Summer     | 2004           |
| 2004     | Summer     | 2001           |
| 2012     | Summer     | 1941           |
| 1996     | Summer     | 1842           |
| 1992     | Summer     | 1712           |
| 1988     | Summer     | 1582           |
| 1984     | Summer     | 1476           |
| 1980     | Summer     | 1384           |
| 1976     | Summer     | 1320           |
| 1920     | Summer     | 1308           |
| 1972     | Summer     | 1215           |
| 1968     | Summer     | 1057           |
| 1964     | Summer     | 1029           |
| 1912     | Summer     | 941            |
| 1936     | Summer     | 917            |
| 1960     | Summer     | 911            |
| 1952     | Summer     | 897            |
| 1956     | Summer     | 893            |
| 1948     | Summer     | 852            |
| 1924     | Summer     | 832            |
| 1908     | Summer     | 831            |
| 1928     | Summer     | 734            |
| 1932     | Summer     | 647            |
| 1900     | Summer     | 604            |
| 2014     | Winter     | 597            |
| 2006     | Winter     | 526            |
| 2010     | Winter     | 520            |
| 1904     | Summer     | 486            |
| 2002     | Winter     | 478            |
| 1906     | Summer     | 458            |
| 1998     | Winter     | 440            |
| 1994     | Winter     | 331            |
| 1992     | Winter     | 318            |
| 1988     | Winter     | 263            |
| 1984     | Winter     | 222            |
| 1980     | Winter     | 218            |
| 1976     | Winter     | 211            |
| 1972     | Winter     | 199            |
| 1968     | Winter     | 199            |
| 1964     | Winter     | 186            |
| 1956     | Winter     | 150            |
| 1960     | Winter     | 147            |
| 1896     | Summer     | 143            |
| 1952     | Winter     | 136            |
| 1948     | Winter     | 135            |
| 1924     | Winter     | 130            |
| 1936     | Winter     | 108            |
| 1932     | Winter     | 92             |
| 1928     | Winter     | 89             |

## 4. ERD

# Project Proposal
--Create tables
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

--Drop the primary key in ID since one athlete can participate in multiple competitions within the same sporting event
SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'athletes' AND constraint_type = 'PRIMARY KEY';

ALTER TABLE athletes
DROP CONSTRAINT athletes_pkey;

--Update SIN to SGP in noc_regions following with athletes table
UPDATE noc_regions
SET noc = 'SGP'
WHERE noc = 'SIN';

-- Insert data into tables
\copy athletes(id, name, sex, age, height, weight, team, noc, games, year, season, city, sport, event, medal) FROM 'C:/Users/Randy V/Downloads/SportsStats/athlete_events.csv' DELIMITER ',' CSV HEADER NULL 'NA';
\copy noc_regions(noc, region, notes) FROM 'C:/Users/Randy V/Downloads/SportsStats/noc_regions.csv' DELIMITER ',' CSV HEADER NULL 'NA';

ALTER TABLE athletes
ALTER COLUMN height TYPE NUMERIC;

ALTER TABLE athletes
ALTER COLUMN weight TYPE NUMERIC;

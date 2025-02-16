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

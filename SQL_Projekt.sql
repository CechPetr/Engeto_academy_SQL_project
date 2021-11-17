#Průměrná denní teplota
CREATE OR REPLACE TABLE `t_weather_day_avg_temp_1` AS 
SELECT 
	`city`,
	CAST (AVG(SUBSTRING_INDEX(temp, ' °', 1)) as FLOAT) AS avg_temp,
	CAST (`date` AS DATE) AS `day`
FROM `weather`
	WHERE (`time` IN ('00:00', '06:00', '12:00', '18:00')) 
	AND (`city` IS NOT NULL OR `city` = '')
GROUP by `city`,`day`;

#Síla větru v nárazech
CREATE OR REPLACE TABLE `t_weather_max_gust` AS
SELECT
	`city`,
	MAX (`gust`) AS `max_gust`,
	CAST (`date` AS DATE) AS `day`
FROM `weather`
	WHERE `city` IS NOT NULL
GROUP BY `city`,`day`;

#Počet hodin kdy byly srážky nenulové
CREATE OR REPLACE TABLE t_weather_rain_prep AS
SELECT 
	`city`,
	COUNT (CAST (REPLACE(`rain`, 'mm', ' ') AS FLOAT)) AS `hours_of_rain`, 
	CAST (`date` AS DATE) AS `day`
FROM `weather` w
	WHERE `rain` > '0.0 mm' AND `city` IS NOT NULL
GROUP BY `city`, `day`;

CREATE OR REPLACE TABLE t_weather_rain AS
SELECT 
	city,
	(hours_of_rain * 3) as hours_of_rain, 
	`day` 
FROM t_weather_rain_prep;

#Tabulka část 3
CREATE OR REPLACE TABLE t_project_part_3 AS
SELECT
	twdat.city,
	twdat.`day`,
	twdat.avg_temp,
	twmg.max_gust,
	twr.hours_of_rain
FROM t_weather_day_avg_temp_1 AS twdat
JOIN t_weather_max_gust AS twmg 
	ON twdat.city = twmg.city
	AND twdat.day = twmg.day
LEFT JOIN t_weather_rain AS twr
	ON twdat.city = twr.city
	AND twdat.day = twr.day;

#Spojovací tabulka města
CREATE OR REPLACE TABLE t_city_alias_table (
	City TEXT(255),
	City_alias TEXT(255)
);

#Hodnoty tabulky
INSERT INTO t_city_alias_table (City, City_alias)
	VALUES ('Amsterdam', 'Amsterdam'),
	('Athens', 'Athenai'),
	('Belgrade', 'Belgrade'),
	('Berlin', 'Berlin'),
	('Bern', 'Bern'),
	('Bratislava', 'Bratislava'),
	('Brussels', 'Bruxelles [Brussel]'),
	('Bucharest', 'Bucuresti'),
	('Budapest', 'Budapest'),
	('Chisinau', 'Chisinau'),
	('Copenhagen', 'Copenhagen'),
	('Dublin', 'Dublin'),
	('Helsinki', 'Helsinki [Helsingfors]'),
	('Kiev', 'Kyiv'),
	('Lisbon', 'Lisboa'),
	('Ljubljana', 'Ljubljana'),
	('London', 'London'),
	('Luxembourg', 'Luxembourg [Luxemburg/L'),
	('Madrid', 'Madrid'),
	('Minsk', 'Minsk'),
	('Moscow', 'Moscow'),
	('Oslo', 'Oslo'),
	('Paris', 'Paris'),
	('Prague', 'Praha'),
	('Riga', 'Riga'),
	('Rome', 'Roma'),
	('Skopje', 'Skopje'),
	('Sofia', 'Sofia'),
	('Stockholm', 'Stockholm'),
	('Tallinn', 'Tallinn'),
	('Tirana', 'Tirana'),
	('Vienna', 'Wien'),
	('Vilnius', 'Vilnius'),
	('Warsaw', 'Warszawa');

ALTER TABLE t_city_alias_table CONVERT TO CHARACTER SET utf8mb4 COLLATE 'utf8mb4_general_ci';

#Religion share prep
CREATE OR REPLACE TABLE t_religion_share_prep AS 
SELECT
	r.country,
	MAX (CASE 
			WHEN r.religion = 'Christianity' THEN r.population
		END) AS Christianity,
	MAX (CASE 
			WHEN r.religion = 'Islam' THEN r.population 
		END) AS Islam,
	MAX (CASE 
			WHEN r.religion = 'Unaffiliated religions' THEN r.population 
		END) AS Unaffiliated_religions,
	MAX (CASE 
			WHEN r.religion = 'Hinduism' THEN r.population 
		END) AS Hinduism,
	MAX (CASE 
			WHEN r.religion = 'Buddhism' THEN r.population 
		END) AS Buddhism,
	MAX (CASE 
			WHEN r.religion = 'Folk religions' THEN r.population 
		END) AS Folk_religions,
	MAX (CASE 
			WHEN r.religion = 'Other religions' THEN r.population 
		END) AS Other_religions,
	MAX (CASE 
			WHEN r.religion = 'Judaism' THEN r.population 
		END) AS Judaism,
	tpp2.population AS country_total_population
FROM religions AS r
JOIN t_project_part_2 AS tpp2
	ON r.country = tpp2.country
	WHERE r.`year` = '2020' AND r.region = 'Europe' AND r.population != '0'
GROUP BY country;

#Religion share
CREATE OR REPLACE TABLE t_religion_share AS
SELECT
	country,
	CAST (ROUND((Christianity/(country_total_population/100)),2) AS FLOAT) AS Christianity_share,
	CAST (ROUND(Islam/(country_total_population/100),2) AS FLOAT) AS Islam_share,
	CAST (ROUND(Unaffiliated_religions/(country_total_population/100),2) AS FLOAT) AS Unaffiliated_religions_share,
	CAST (ROUND(Hinduism/(country_total_population/100),2) AS FLOAT) AS Hinduism_share,
	CAST (ROUND(Buddhism/(country_total_population/100),2) AS FLOAT) AS Buddhism_share,
	CAST (ROUND(Folk_religions/(country_total_population/100),2) AS FLOAT) AS Folk_religions_share,
	CAST (ROUND(Other_religions/(country_total_population/100),2) AS FLOAT) AS Other_religions_share,
	CAST (ROUND(Judaism/(country_total_population/100),2) AS FLOAT) AS Judaism_share
FROM t_religion_share_prep trsp;

#Population density, median age
CREATE OR REPLACE TABLE t_population_density_median_age AS
SELECT
	c.country,
	c.capital_city,
	CAST (c.population_density AS FLOAT) AS population_density,
	CAST (c.population AS FLOAT) AS population,
	CAST (c.median_age_2018 AS FLOAT) AS median_age_2018
FROM countries AS c
JOIN religions AS r
	ON c.country = r.country
	WHERE r.`year` = '2020'
GROUP BY c.country;

#Rozdíl mezi očekávanou dobou dožití
CREATE OR REPLACE TABLE t_life_expectancy_diff AS
SELECT 
	le1.country,
	CAST (le1.life_expectancy AS FLOAT) AS life_expectancy_1965,
	CAST (le2.life_expectancy AS FLOAT) AS life_expectancy_2015,
	CAST (ROUND (le2.life_expectancy-le1.life_expectancy, 2) AS FLOAT) AS life_expectancy_diff
FROM life_expectancy AS le1
JOIN life_expectancy AS le2
	ON le1.country = le2.country
	WHERE le1.`year` = '1965' AND le2.`year` = '2015';

#HDP, GINY, dětská úmrtnost
CREATE OR REPLACE TABLE t_GDP_GINY_CHL_deaths AS
SELECT
	country,
	gini,
	mortaliy_under5,
	MAX (`year`) AS year,
	ROUND (GDP/population, 2) AS GDP_per_resident
FROM economies
	WHERE gini IS NOT NULL
GROUP BY country; 

#Tabulka část 2
CREATE OR REPLACE TABLE t_project_part_2 AS
SELECT 
	tpdma.*,
	tled.life_expectancy_diff,
	tggcd.GDP_per_resident,
	tggcd.gini,
	tggcd.mortaliy_under5,
	trs.Christianity_share,
	trs.Islam_share,
	trs.Unaffiliated_religions_share,
	trs.Hinduism_share,
	trs.Buddhism_share,
	trs.Folk_religions_share,
	trs.Other_religions_share,
	trs.Judaism_share
FROM t_population_density_median_age AS tpdma 
JOIN t_life_expectancy_diff AS tled
		ON tpdma.country = tled.country
JOIN t_GDP_GINY_CHL_deaths AS tggcd
	ON tpdma.country = tggcd.country
JOIN t_religion_share AS trs 
	ON tpdma.country = trs.country;

#Dny v tydnu, roční období
CREATE OR REPLACE TABLE t_day_of_week_seasons AS
SELECT 
	`date`,
	country,
	confirmed,
CASE
	WHEN
	DAYOFWEEK(`date`) IN ("2", "3", "4", "5", "6") THEN 1
	ELSE 0 
	END den_v_tydnu,
CASE 
	WHEN MONTH(date) IN (12, 1, 2) THEN 3 
		WHEN MONTH(date) = 3 THEN 
			CASE 
				WHEN DAY(date) <= 19 THEN 3
			ELSE 0
		END
	WHEN MONTH(date) IN (3, 4, 5) THEN 0 
		WHEN MONTH(date) = 6 then 
			CASE 
				WHEN DAY(date) <= 19 THEN 0
			ELSE 1
		END
	WHEN MONTH(date) IN (6, 7, 8) THEN 1 
		WHEN MONTH(date) = 9 THEN 
			CASE 
				WHEN DAY(date) <= 21 THEN 1
			ELSE 2
		END
	WHEN MONTH(date) IN (9, 10, 11) THEN 2 
		WHEN MONTH(date) = 12 THEN 
			CASE 
				WHEN DAY(date) <= 20 THEN 2
			ELSE 3
		END
	END AS rocni_obdobi
FROM covid19_basic_differences cbd;

#Počet provedených testů
CREATE OR REPLACE TABLE t_covid_tests AS
SELECT 
	country,
	`date`,
	tests_performed
FROM covid19_tests ct;

#Spojovací tabulka země
CREATE OR REPLACE TABLE t_country_alias_table (
	Country TEXT(255),
	Country_alias TEXT(255)
);

#Hodnoty tabulky
INSERT INTO t_country_alias_table (Country, Country_alias)
	VALUES ('Albania', 'Albania'),
	('Austria', 'Austria'),
	('Belarus', 'Belarus'),
	('Belgium', 'Belgium'),
	('Bulgaria', 'Bulgaria'),
	('Czech republic', 'Czechia'),
	('Denmark', 'Denmark'),
	('Estonia', 'Estonia'),
	('Finland', 'Finland'),
	('France', 'France'),
	('Germany', 'Germany'),
	('Greece', 'Greece'),
	('Hungary', 'Hungary'),
	('Ireland', 'Ireland'),
	('Italy', 'Italy'),
	('Latvia', 'Latvia'),
	('Lithuania', 'Lithuania'),
	('Luxembourg', 'Luxembourg'),
	('Moldova', 'Moldova'),
	('Netherlands', 'Netherlands'),
	('North Macedonia', 'North Macedonia'),
	('Norway', 'Norway'),
	('Poland', 'Poland'),
	('Portugal', 'Portugal'),
	('Romania', 'Romania'),
	('Russian Federation', 'Russia'),
	('Serbia', 'Serbia'),
	('Slovakia', 'Slovakia'),
	('Slovenia', 'Slovenia'),
	('Spain', 'Spain'),
	('Sweden', 'Sweden'),
	('Switzerland', 'Switzerland'),
	('Ukraine', 'Ukraine'),
	('United Kingdom', 'United Kingdom');

ALTER TABLE t_country_alias_table CONVERT TO CHARACTER SET utf8mb4 COLLATE 'utf8mb4_general_ci';

#Tabluka část 1
CREATE OR REPLACE TABLE t_project_part_1 AS
SELECT
	tdows.*,
	tct.tests_performed
FROM t_day_of_week_seasons AS tdows 
JOIN t_country_alias_table AS tcat 
	ON tdows.country = tcat.Country_alias
LEFT JOIN t_covid_tests AS tct
	ON tct.country = tcat.Country 
	AND tdows.`date` = tct.`date`;

#Spojení tabulek 2,3
CREATE OR REPLACE TABLE t_spojeni_2_3 AS
SELECT
	tpp2.*,
	tpp3.`day` ,
	tpp3.avg_temp ,
	tpp3.max_gust,
	tpp3.hours_of_rain 
FROM t_project_part_2 AS tpp2
JOIN t_city_alias_table AS tcat 
	ON tpp2.capital_city = tcat.City_alias
JOIN t_project_part_3 AS tpp3
	ON tcat.City = tpp3.city
group by tpp2.country, tpp3.day;

#Spojeni tabulek 1,2,3
CREATE OR REPLACE TABLE t_petr_cech_projekt_SQL_final AS
SELECT
	tpp1.country,
	tpp1.`date`,
	tpp1.confirmed,
	tpp1.tests_performed,
	ts.population,
	tpp1.den_v_tydnu,
	tpp1.rocni_obdobi,
	ts.population_density,
	ts.GDP_per_resident,
	ts.gini,
	ts.mortaliy_under5,
	ts.median_age_2018,
	ts.Christianity_share,
	ts.Islam_share,
	ts.Unaffiliated_religions_share,
	ts.Hinduism_share,
	ts.Buddhism_share,
	ts.Folk_religions_share,
	ts.Other_religions_share,
	ts.Judaism_share,
	ts.life_expectancy_diff,
	ts.avg_temp,
	ts.hours_of_rain,
	ts.max_gust
FROM t_project_part_1 AS tpp1
JOIN t_country_alias_table AS tcat
	ON tpp1.country = tcat.Country_alias
JOIN t_spojeni_2_3 AS ts 
	ON ts.country = tcat.Country
	AND tpp1.`date` = ts.`day`
ORDER BY tpp1.country, tpp1.`date`;



#Průměrná denní teplota
CREATE OR REPLACE TABLE `t_weather_day_avg_temp_1` AS 
SELECT 
`city`,
CAST (AVG(SUBSTRING_INDEX(temp, ' °', 1)) as float) as avg_temp,
CAST (`date` as date) AS `day`
FROM `weather`
WHERE (`time` in ('00:00', '06:00', '12:00', '18:00')) 
and (`city` is not NULL or `city` = '')
GROUP by `city`,`day`;

#Síla větru v nárazech
CREATE OR REPLACE TABLE `t_weather_max_gust` AS
SELECT
	`city`,
	max(`gust`) AS `max_gust`,
	cast (`date` as date) AS `day`
FROM `weather`
where `city` is not NULL
group by `city`,`day`;

#Počet hodin kdy byly srážky nenulové
CREATE OR REPLACE TABLE t_weather_rain_prep AS
SELECT 
	`city`,
	COUNT(`rain`) AS `hours_of_rain`, 
	CAST (`date` as date) AS `day`
FROM `weather` w
WHERE `rain` > '0.0 mm' and `city` is not NULL
group by `city`, `day`;

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
	City text(255),
	City_alias text(255)
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
	WHEN r.religion = 'Christianity' then r.population
	END) AS Christianity,
MAX (CASE 
	WHEN r.religion = 'Islam' then r.population 
	END) AS Islam,
MAX (CASE 
	WHEN r.religion = 'Unaffiliated religions' then r.population 
	END) AS Unaffiliated_religions,
MAX (CASE 
	WHEN r.religion = 'Hinduism' then r.population 
	END) AS Hinduism,
MAX (CASE 
	WHEN r.religion = 'Buddhism' then r.population 
	END) AS Buddhism,
MAX (CASE 
	WHEN r.religion = 'Folk religions' then r.population 
	END) AS Folk_religions,
MAX (CASE 
	WHEN r.religion = 'Other religions' then r.population 
	END) AS Other_religions,
MAX (CASE 
	WHEN r.religion = 'Judaism' then r.population 
	END) AS Judaism,
tpp2.population AS country_total_population
FROM religions AS r
JOIN t_project_part_2 AS tpp2
ON r.country = tpp2.country
where r.`year` = '2020' and r.region = 'Europe' and r.population != '0'
group by country;

#Religion share
CREATE OR REPLACE TABLE t_religion_share AS
SELECT
country,
CAST (ROUND((Christianity/(country_total_population/100)),2) as float) AS Christianity_share,
CAST (ROUND(Islam/(country_total_population/100),2) as float) AS Islam_share,
CAST (ROUND(Unaffiliated_religions/(country_total_population/100),2) as float) AS Unaffiliated_religions_share,
CAST (ROUND(Hinduism/(country_total_population/100),2) as float) AS Hinduism_share,
CAST (ROUND(Buddhism/(country_total_population/100),2) as float) AS Buddhism_share,
CAST (ROUND(Folk_religions/(country_total_population/100),2) as float) AS Folk_religions_share,
CAST (ROUND(Other_religions/(country_total_population/100),2) as float) AS Other_religions_share,
CAST (ROUND(Judaism/(country_total_population/100),2) as float) AS Judaism_share
FROM t_religion_share_prep trsp;

#Population density, median age
CREATE OR REPLACE TABLE t_population_density_median_age AS
SELECT
	c.country,
	c.capital_city,
	CAST (c.population_density as float) AS population_density,
	CAST (c.population as float) AS population,
	CAST (c.median_age_2018 as float) AS median_age_2018
FROM countries AS c
JOIN religions AS r
	ON c.country = r.country
WHERE r.`year` = '2020'
GROUP BY c.country;

#Rozdíl mezi očekávanou dobou dožití
CREATE OR REPLACE TABLE t_life_expectancy_diff AS
SELECT 
	le1.country,
	CAST (le1.life_expectancy as float) AS life_expectancy_1965,
	CAST (le2.life_expectancy as float) AS life_expectancy_2015,
	CAST (ROUND (le2.life_expectancy-le1.life_expectancy, 2) as float) AS life_expectancy_diff
FROM life_expectancy AS le1
JOIN life_expectancy AS le2
	ON le1.country = le2.country
WHERE 
	le1.`year` = '1965' and le2.`year` = '2015';

#HDP, GINY, dětská úmrtnost
CREATE OR REPLACE TABLE t_GDP_GINY_CHL_deaths AS
SELECT
country,
gini,
mortaliy_under5,
max(`year`) as year,
ROUND (GDP/population, 2) AS GDP_per_resident
from economies
where gini is not null
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
	when
	DAYOFWEEK(`date`) in ("2", "3", "4", "5", "6") then 1
	else 0 
	end den_v_tydnu,
CASE 
	WHEN date BETWEEN '2019-12-21' and '2020-03-19' then 3
	WHEN date between '2020-03-20' and '2020-06-19' then 0
	WHEN date BETWEEN '2020-06-20' and '2020-09-21' then 1
	WHEN date BETWEEN '2020-09-22' and '2020-12-20' then 2
	WHEN date BETWEEN '2020-12-21' and '2021-03-19' then 3
	WHEN date between '2021-03-20' and '2021-06-19' then 0
	END as rocni_obdobi
from covid19_basic_differences cbd;

#Počet provedených testů
CREATE OR REPLACE TABLE t_covid_tests AS
SELECT 
country,
`date`,
tests_performed
FROM covid19_tests ct;
#Spojovací tabulka země
CREATE OR REPLACE TABLE t_country_alias_table (
	Country text(255),
	Country_alias text(255)
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
order by tpp1.country, tpp1.`date`;



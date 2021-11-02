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
CREATE OR REPLACE TABLE `t_weather_rain` AS
SELECT 
	`city`,
	COUNT(`rain`) AS `hours_of_rain`, 
	CAST (`date` as date) AS `day`
FROM `weather` w
WHERE `rain` > '0.0 mm' and `city` is not NULL
group by `city`, `day`;

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
	
#Population density, median age, religion
CREATE OR REPLACE TABLE t_religion_share AS

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

CREATE OR REPLACE TABLE t_project_part_2 AS
SELECT 
tpdma.*,
tled.life_expectancy_diff,
tggcd.GDP_per_resident,
tggcd.gini,
tggcd.mortaliy_under5
FROM t_population_density_median_age AS tpdma 
JOIN t_life_expectancy_diff AS tled
	ON tpdma.country = tled.country
JOIN t_GDP_GINY_CHL_deaths AS tggcd
	ON tpdma.country = tggcd.country;
	
	
SELECT 
*
from religions r
where (year = '2020' and region = 'Europe') and population != 0;

	
	
	

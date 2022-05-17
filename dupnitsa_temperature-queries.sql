-- Describe table
DESCRIBE dupnitsa;

-- Change type of a column
ALTER TABLE dupnitsa MODIFY COLUMN tmin INT;

-- Select all
SELECT * FROM dupnitsa;

-- Count distinct dates
SELECT COUNT(DISTINCT date) AS Dates FROM dupnitsa;

-- Type of the column
SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dupnitsa' AND COLUMN_NAME = 'date';

DESCRIBE dupnitsa date;

-- Extract year, month, day and difference
SELECT * FROM (
  SELECT
    date, tmin, tmax,
  	EXTRACT(YEAR FROM date) AS "year",
  	EXTRACT(MONTH FROM date) AS "month",
  	MONTHNAME(date) AS "month name",
  	EXTRACT(DAY FROM date) AS "day",
	DAYOFWEEK(date) AS "day of week",
  	DAYNAME(date) AS "day of week name",
  	DAYOFYEAR(date) AS "day of year",
	EXTRACT(WEEK FROM date) AS "week of year",
	EXTRACT(QUARTER FROM date) AS "quarter",
  	IF(tmin IS NOT NULL AND tmax IS NOT NULL, tmax-tmin, 0) AS "diff"
  FROM dupnitsa
) AS Date;

-- Rolling averages 2 days
SELECT
  date, tavg,
  Round((SELECT SUM(tavg) / COUNT(tavg) FROM dupnitsa AS b
         WHERE DATEDIFF(a.date, b.date) BETWEEN 0 AND 2),2) AS 'Rolling Averages 2 days'
FROM dupnitsa AS a
ORDER BY date;


SELECT
  date,tavg,
  AVG (tavg) OVER (ORDER BY date ASC RANGE INTERVAL 2 DAY PRECEDING) AS 'Rolling Averages 2 days'
FROM dupnitsa
WHERE date <= DATE '2014-12-30'
ORDER BY date ASC

-- Avg by day of the week
SELECT 
	DISTINCT DAYOFWEEK(date) AS day_of_week, 
	AVG(tavg) OVER(PARTITION BY DAYOFWEEK(date)) AS avg_temp_by_day
FROM dupnitsa


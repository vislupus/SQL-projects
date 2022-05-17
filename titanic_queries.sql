https://www.db-fiddle.com/f/583XxT4cSJ5bd7pss4fiBe/9

-- Select all
SELECT * FROM titanic

-- Select all female on the ship
SELECT * FROM titanic  WHERE 'female' IN (sex);
SELECT * FROM titanic WHERE sibsp IN (1, 2, 3);

-- Select the oldest person on the ship
SELECT * FROM titanic
WHERE age = (SELECT MAX(age) FROM titanic);

-- Count number of rows
SELECT COUNT(DISTINCT id) FROM titanic

-- Count occurrences of sex
SELECT sex, COUNT(sex) FROM titanic
GROUP BY sex

-- Count occurrences of age
SELECT age, COUNT(*) FROM titanic
WHERE age IS NOT NULL
GROUP BY age 
HAVING COUNT(*)>=20 
ORDER BY age

-- Count number of people on age and their sex
SELECT age,
COUNT(age) AS number_of_people,
COUNT(NULLIF(sex, 'male')) AS female,
COUNT(NULLIF(sex, 'female')) AS male
FROM titanic
WHERE age IS NOT NULL AND age>=30 AND age<40
GROUP BY age
ORDER BY number_of_people DESC

-- Average age by sex
SELECT sex, AVG(age) AS 'Avg age' FROM titanic
GROUP BY sex

-- Average age by sex and pclass
SELECT pclass, sex, age, 
AVG(age) OVER(PARTITION BY sex) AS avg_age_by_sex, 
AVG(age) OVER(PARTITION BY pclass) AS avg_age_by_pclass, 
COUNT(age) OVER(PARTITION BY pclass) AS count_age_by_pclass,
COUNT(CASE WHEN age IS NOT NULL THEN age ELSE NULL END) OVER (PARTITION BY sex)
FROM titanic
WHERE age>=70;

-- Max age of number of siblings
SELECT sibsp, MAX(age) AS 'max_age' FROM titanic 
GROUP BY sibsp
HAVING max_age > 30
ORDER BY sibsp;

-- Length of the names
SELECT * FROM (
  SELECT name, MAX(CHAR_LENGTH(name)) AS 'max_length' 
  FROM titanic
  GROUP BY name
) AS Length
WHERE max_length>50;


-- Filter by max, min, avg age with veritable
SET @max_age:=(SELECT MAX(age) FROM titanic);
SET @avg_age:=(SELECT AVG(age) FROM titanic);
SET @min_age:=(SELECT MIN(age) FROM titanic);
SELECT @max_age, @avg_age, @min_age;
SELECT * FROM titanic WHERE age<@avg_age;
----------------------------------------------------
SELECT 'max' AS 'function', MAX(age) AS 'value' FROM titanic
UNION (SELECT 'min' AS 'function', MIN(age) AS 'value' FROM titanic)
UNION (SELECT 'avg' AS 'function', AVG(age) AS 'value' FROM titanic)
UNION (SELECT 'sum' AS 'function', SUM(age) AS 'value' FROM titanic)
UNION (SELECT 'std' AS 'function', STDDEV(age) AS 'value' FROM titanic)
UNION (SELECT 'count' AS 'function', COUNT(age) AS 'value' FROM titanic);

-- Correlation
SELECT  
(AVG(age*pclass)-AVG(age)*AVG(pclass))/(SQRT(AVG(age*age)-AVG(age)*AVG(age))*SQRT(AVG(pclass*pclass)-AVG(pclass)*AVG(pclass))) AS correlation_coefficient_population,
(COUNT(age)*SUM(age*pclass)-SUM(age)*SUM(pclass))/(SQRT(COUNT(age)*SUM(age*age)-SUM(age)*SUM(age))*SQRT(COUNT(age)*SUM(pclass*pclass)-SUM(pclass)*SUM(pclass))) AS correlation_coefficient_sample
FROM titanic WHERE age IS NOT NULL;
----------------------------------------------------------
SELECT (COUNT(age)*SUM(age*pclass)-SUM(age)*SUM(pclass))/SQRT((COUNT(age)*SUM(age*age)-(SUM(age)*SUM(age)))*(COUNT(age)*SUM(pclass*pclass)-(SUM(pclass)*SUM(pclass)))) AS 'Pearson’s correlation coefficient'
FROM titanic WHERE age IS NOT NULL;

-- Get the names of the columns as a text
SELECT GROUP_CONCAT(column_name) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='titanic' ORDER BY ordinal_position

-- Search in all columns for ?
SELECT * FROM titanic  WHERE '?' in (id,pclass,survived,name,sex,age,sibsp,parch,ticket,fare,cabin,embarked,boat,body,home_dest);

-- Replace ? in the columns
SELECT REPLACE(boat, '?','') FROM titanic
UPDATE titanic SET age=REPLACE(age, '?',''), fare=REPLACE(fare, '?',''), cabin=REPLACE(cabin, '?',''), embarked=REPLACE(embarked, '?',''), boat=REPLACE(boat, '?',''), body=REPLACE(body, '?',''), home_dest=REPLACE(home_dest, '?','');

-- String manipulation
SELECT * FROM (
  SELECT 
    name, 
    MAX(CHAR_LENGTH(name)) AS 'max_length',
  	REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(name, ',', -1), '.', -1), ' ', 2), '(','') AS 'first_name',
  	SUBSTRING_INDEX(name, ',', 1) AS 'last_name',
  	SUBSTRING_INDEX(SUBSTRING_INDEX(name, ',', -1), '.', 1) AS 'title'
  FROM titanic 
  GROUP BY name
) AS Length
WHERE max_length>50;

-- Add column to the table
ALTER TABLE titanic ADD COLUMN title VARCHAR(22) AFTER name;
UPDATE titanic SET title = SUBSTRING_INDEX(SUBSTRING_INDEX(name, ',', -1), '.', 1)
WHERE title IS NULL;

-- Select number of peoples with title
SELECT title, COUNT(title) AS 'count_title' FROM titanic 
GROUP BY title ORDER BY count_title DESC;

-- Create histogram
SET @total_rows = (SELECT COUNT(*) FROM titanic WHERE age IS NOT NULL);
SELECT floor(age/5)*5 AS bins,
       COUNT(*) AS count,
       RPAD('', LN(COUNT(*)), '*') AS bar,
       round(COUNT(*)/5, 1) AS frequency,
       COUNT(*)/@total_rows AS probability,
       round(COUNT(*)/5, 1)/@total_rows AS density
FROM titanic Where age IS NOT NULL
GROUP BY bins
ORDER BY bins;
---------------------------------------------------------------------------
SELECT "0-10" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 0 AND 10
UNION (SELECT "10-20" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 10 AND 20)
UNION (SELECT "20-30" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 20 AND 30)
UNION (SELECT "30-40" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 30 AND 40)
UNION (SELECT "40-50" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 40 AND 50)
UNION (SELECT "40-50" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 40 AND 50)
UNION (SELECT "50-60" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 50 AND 60)
UNION (SELECT "60-100" AS TotalRange, COUNT(age) AS Count FROM titanic WHERE age BETWEEN 60 AND 100);





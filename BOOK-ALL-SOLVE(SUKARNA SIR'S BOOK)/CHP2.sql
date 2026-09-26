--2.1

-- Practice 2.1
-- a. Write an SQL query to retrieve all country names.
-- b. Write an SQL query to retrieve all job titles.
-- c. Write an SQL query to retrieve all MANAGER_IDs.
-- d. Write an SQL query to retrieve all city names. Remove duplicate outputs.
-- e. Write an SQL query to retrieve LOCATION_ID, ADDRESS from LOCATIONS table. The
-- ADDRESS should print each location in the following format: STREET_ADDRESS, CITY,
-- STATE_PROVINCE, POSTAL_CODE.
--A 

SELECT COUNTRY_NAME
FROM COUNTRIES;

--B
SELECT JOB_TITLE
FROM JOBS;

--C 
SELECT MANAGER_ID 
FROM DEPARTMENTS;

--D 
SELECT DISTINCT CITY
FROM LOCATIONS;
--E
SELECT LOCATION_ID, STREET_ADDRESS || CITY || STATE_PROVINCE ||POSTAL_CODE AS ADDRESS
FROM LOCATIONS;



-- Practice 2.2

-- Practice 2.2
-- a. Select names of all employees who have joined before January 01, 1998.
-- b. Select all locations in the following countries: Canada, Germany, United Kingdom.
-- c. Select first names of all employees who do not get any commission.
-- d. Select first names of employees whose last name starts with an 'a'.
-- e. Select first names of employees whose last name starts with an 's' and ends with an 'n'.
-- f. Select all department names whose MANAGER_ID is 100.
-- g. Select all names of employees whose job type is 'AD_PRES' and whose salary is at least 23000.
-- h. Select names of all employees whose last name do not contain the character 's'.
-- i. Select names and COMMISSION_PCT of all employees whose commission is at most 0.30.
-- j. Select names of all employees who have joined after January 01, 1998.
-- k. Select names of all employees who have joined in the year 1998.

-- a
SELECT first_name, last_name
FROM employees
WHERE hire_date < TO_DATE('01-JAN-1998', 'DD-MON-YYYY');

-- b
SELECT *
FROM locations
WHERE country_id IN (
    SELECT country_id
    FROM countries
    WHERE country_name IN ('Canada', 'Germany', 'United Kingdom')
);

-- c
SELECT first_name
FROM employees
WHERE commission_pct IS NULL;

-- d
SELECT first_name
FROM employees
WHERE last_name LIKE 'A%';

-- e
SELECT first_name
FROM employees
WHERE last_name LIKE 'S%n';

-- f
SELECT department_name
FROM departments
WHERE manager_id = 100;

-- g
SELECT first_name, last_name
FROM employees
WHERE job_id = 'AD_PRES'
  AND salary >= 23000;

-- h
SELECT first_name, last_name
FROM employees
WHERE last_name NOT LIKE '%s%';

-- i
SELECT first_name, last_name, commission_pct
FROM employees
WHERE commission_pct <= 0.30;

-- j
SELECT first_name, last_name
FROM employees
WHERE hire_date > TO_DATE('01-JAN-1998', 'DD-MON-YYYY');

-- k
SELECT first_name, last_name
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 1998;


-- Practice 2.3


-- Practice 2.3
-- a. Select names, salary, and commissions of all employees of job type 'AD_PRES'. Sort the result
-- in ascending order of commission and then descending order of salary.
-- b. Retrieve all country names in lexicographical ascending order.

-- a
SELECT first_name, last_name, salary, commission_pct
FROM employees
WHERE job_id = 'AD_PRES'
ORDER BY commission_pct ASC, salary DESC;

-- b
SELECT country_name
FROM countries
ORDER BY country_name ASC;


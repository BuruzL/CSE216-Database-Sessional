--1
--Find employees who are either in departments with more than 5 employees or have a job title
-- with a minimum salary above 10000, or both. Exclude those in departments where the manager
-- earns less than their department's average.
SELECT E.EMPLOYEE_ID 
FROM EMPLOYEES E 
JOIN EMPLOYEES M 
ON D.MANAGER_ID=M.EMPLOYEE_ID 
JOIN JOBS J 
ON E.JOB_ID=J.JOB_ID 
WHERE (J.MIN_SALARY>10000
OR (
    SELECT COUNT(*)
    FROM EMPLOYEES EE 
    WHERE E.DEPARTMENT_ID=EE.DEPARTMENT_ID
)>5)
AND M.SALARY>(
    SELECT AVG(EEE.SALARY)
    FROM EMPLOYEES EEE 
    WHERE E.DEPARTMENT_ID=EEE.DEPARTMENT_ID
)
GROUP BY E.DEPARTMENT_ID , E.EMPLOYEE_ID;


--2. For each country, count the number of departments. Display only the country_name and
-- department_count, in ascending order of the country_name. Include the countries having no
-- departments, too.

SELECT C.COUNTRY_NAME , COUNT(D.DEPARTMENT_ID) DEPTCNT 
FROM COUNTRIES C  
LEFT JOIN LOCATIONS L 
ON C.COUNTRY_ID=L.COUNTRY_ID 
LEFT JOIN DEPARTMENTS D 
ON D.LOCATION_ID=L.LOCATION_ID 
GROUP BY C.COUNTRY_ID, C.COUNTRY_NAME 
ORDER BY C.COUNTRY_NAME ASC;

--3. For each department, find the employee_id, full_name, salary, department_name, and job title of
-- the second-highest-paid employee(s) i.e. employee(s) having the second-highest salary. If a
-- department has fewer than two employees, do not include it in the results. Display the output in
-- descending order of the salary. If two employees have the same salary, prioritize the one whose
-- department name is lexicographically smaller. If a tie still exists, prioritize the employee with the
-- lower employee_id.

SELECT E.EMPLOYEE_ID, E.FIRST_NAME,D.DEPARTMENT_NAME, J.JOB_TITLE
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID 
JOIN JOBS J 
ON J.JOB_ID=E.JOB_ID 
WHERE E.SALARY=(
    SELECT MAX(EE.SALARY)
    FROM EMPLOYEES EE
    WHERE E.DEPARTMENT_ID=EE.DEPARTMENT_ID 
    AND EE.SALARY<(
        SELECT MAX(EEE.SALARY)
        FROM EMPLOYEES EEE 
        WHERE EEE.DEPARTMENT_ID=E.DEPARTMENT_ID
    )
)
AND (
    SELECT COUNT(*)
    FROM EMPLOYEES E4 
    WHERE E.DEPARTMENT_ID=E4.DEPARTMENT_ID
)>=2
ORDER BY E.SALARY DESC,
         D.DEPARTMENT_NAME ASC,
         E.EMPLOYEE_ID ASC;


-- 4. Find the employee_id, first_name, and salary of employees in descending order of the salary and
-- ascending order of the employee ID, who meet exactly one of the following two conditions:
-- a. They report to a manager whose salary is greater than 15000.
-- b. They work in a department located in 'Seattle'.

SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.SALARY
FROM EMPLOYEES E 
JOIN EMPLOYEES M 
ON E.MANAGER_ID=M.EMPLOYEE_ID 
JOIN DEPARTMENTS D 
ON D.DEPARTMENT_ID=E.DEPARTMENT_ID 
JOIN LOCATIONS L 
ON D.LOCATION_ID=L.LOCATION_ID 
WHERE (
    (
        M.SALARY>15000
    ) AND NOT(
        L.CITY IN ('Seattle')
    )
)OR(
    (
         L.CITY IN ('Seattle')
    )AND NOT(
         M.SALARY>15000
    )
)
ORDER BY EMPLOYEE_ID ASC;

-- 5. Find employees (first and last name), their departments, and salary, for those who earn more than
-- the average salary in their own department. Only consider departments where there is at least one
-- employee earning less than the company average salary and at least one earning more than the
-- company average salary. Use a CASE statement to categorize salary as 'High' (if above 10,000),
-- 'Medium' (if between 5,000 and 10,000), or 'Low' (if below 5,000).


SELECT E.FIRST_NAME, D.DEPARTMENT_NAME, E.SALARY,
(CASE
    WHEN E.SALARY>10000 THEN 'HIGH'
    WHEN E.SALARY BETWEEN 5000 AND 10000 THEN 'MID'
    WHEN E.SALARY<5000 THEN 'MID'
END
)AS SALARY_TAG 
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID 
WHERE E.SALARY > (
    SELECT AVG(EE.SALARY)
    FROM EMPLOYEES EE
    WHERE EE.DEPARTMENT_ID = E.DEPARTMENT_ID
)
AND (
    SELECT COUNT(*)
    FROM EMPLOYEES EE 
    WHERE EE.SALARY<(
        SELECT AVG(SALARY)
        FROM EMPLOYEES 
    )
)>=1 
AND (
    SELECT COUNT(*)
    FROM EMPLOYEES EE 
    WHERE EE.SALARY>(
        SELECT AVG(SALARY)
        FROM EMPLOYEES 
    )
)>=1 ;







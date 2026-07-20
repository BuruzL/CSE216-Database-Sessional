-- 1. List managers whose departments have
--  average salaries higher than the overall company average,
-- for departments located in Toronto and Oxford.


SELECT M.EMPLOYEE_ID AS MANAGER_ID,
M.FIRST_NAME||' '||M.LAST_NAME AS MANAGER_NAME,
D.DEPARTMENT_NAME,
ROUND(AVG(E.SALARY),2) AS DEPT_AVG_SAL
FROM DEPARTMENT_ID D 
JOIN LOCATIONS L 
ON D.LOCATION_ID=L.LOCATIONS_ID
JOIN EMPLOYEES E 
ON D.DEPARTMENT_ID=E.DEPARTMENT_ID
JOIN EMPLOYEES M 
ON D.MANAGER_ID=M.EMPLOYEE_ID
WHERE L.CITY IN ('TORONTO', 'OXFORD')
GROUP BY 
M.EMPLOYEE_ID,
M.FIRST_NAME,
M.LAST_NAME,
D.DEPARTMENT_ID,
D.DEPARTMENT_NAME
HAVING AVG(E.SALARY)>(
    SELECT AVG(SALARY)
    FROM EMPLOYEES
)
ORDER BY DEPT_AVG_SAL;

-- Find employees who both work in departments
--  with more than 5 employees AND have salaries
-- greater than the overall average salary across all employees.

SELECT E.EMPLOYEE_ID,
E.FIRST_NAME,
E.LAST_NAME,
E.DEPARTMENT_ID,
E.JOB_ID,
E.SALARY
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
WHERE E.DEPARTMENT_ID IN(
    SELECT E.DEPARTMENT_ID
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID IS NOT NULL 
    GROUP BY DEPARTMENT_ID      
    HAVING COUNT(*)>5
)
AND E.SALARY>(
    SELECT AVG(E3.SALARY)
    FROM EMPLOYEES E3 
)
ORDER BY E.DEPARTMENT_ID, E.SALARY DESC;


-- Write a SQL query for employees in departments
--  that have managers, with no job history records,
-- and salary > dept average. Show full_name, salary, 
-- dept_name, and label 'Stable High Earner' if
-- salary > 1.7 times dept average, else 'Dept Above Avg'.

SELECT E.FIRST_NAME||' '||E.LAST_NAME AS FULL_NAME,
E.SALARY,
D.DEPARTMENT_NAME,
CASE 
    WHEN E.SALARY>1.7*(
        SELECT AVG(SALARY)
        FROM EMPLOYEES E2
        WHERE E2.DEPARTMENT_ID=E.DEPARTMENT_ID
    ) THEN 'STABLE HIGH EARNER'
    ELSE 'DEPT ABOVE AVG'
    END AS LABEL_SAL 
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
WHERE D.MANAGER_ID IS NOT NULL
AND NOT EXISTS(
    SELECT 1
    FROM JOB_HISTORY JH 
    WHERE JH.EMPLOYEE_ID=E.EMPLOYEE_ID
)
AND E.SALARY>(
    SELECT AVG(E3.SALARY)
    FROM EMPLOYEES E3
    WHERE E3.DEPARTMENT_ID=E.DEPARTMENT_ID
)
ORDER BY E.SALARY ASC;


-- Find employees who are either in departments with more
--  than 5 employees or have a job with
-- minimum salary above 10000.
-- Display: employee_id, first_name, last_name,
--  department_id, job_id, salary.

SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME,
E.DEPARTMENT_ID, E.JOB_ID, E.salary
FROM EMPLOYEES E 
JOIN JOBS J 
ON J.JOB_ID=E.JOB_ID
WHERE E.DEPARTMENT_ID IN (
    SELECT E2.DEPARTMENT_ID
    FROM EMPLOYEES E2
    WHERE E2.DEPARTMENT_ID IS NOT null
    GROUP BY E2.DEPARTMENT_ID 
    HAVING COUNT(*)>5
)
OR J.MIN_SALARY>10000
ORDER BY E.EMPLOYEE_ID;


-- 5. Write an SQL query to find employees who satisfy 
-- exactly one of the following conditions:
-- (i) they work in a department with more than 5
--  employees, or
-- (ii) their job has a minimum salary greater than 10000.
-- Employees who satisfy both conditions or neither
--  condition must be excluded. Display employee
-- ID, full name, department ID, job ID, and salary.

SELECT E.EMPLOYEE_ID, E.FIRST_NAME || ' ' || E.LAST_NAME AS FULL_NAME, E.DEPARTMENT_ID, E.JOB_ID, E.salary
FROM EMPLOYEES E 
JOIN JOBS J 
ON J.JOB_ID=E.JOB_ID
WHERE (E.DEPARTMENT_ID IN (
    SELECT E2.DEPARTMENT_ID
    FROM EMPLOYEES E2
    WHERE E2.DEPARTMENT_ID IS NOT null
    GROUP BY E2.DEPARTMENT_ID 
    HAVING COUNT(*)>5
) AND J.MIN_SALARY<=10000)
OR ( E.DEPARTMENT_ID NOT IN (
    SELECT E2.DEPARTMENT_ID
    FROM EMPLOYEES E2
    WHERE E2.DEPARTMENT_ID IS NOT null
    GROUP BY E2.DEPARTMENT_ID 
    HAVING COUNT(*)>5
) AND J.MIN_SALARY>10000)
ORDER BY E.EMPLOYEE_ID;

--Find job titles in departments where employees have worked more than 5 years on average, but
-- only include those jobs which have a maximum salary higher than the average max salary across
-- all jobs.

SELECT DISTINCT J.JOB_TITLE
FROM EMPLOYEES E 
JOIN  JOBS J 
ON J.JOB_ID=E.JOB_ID
WHERE E.DEPARTMENT_ID IN(
    SELECT DEPARTMENT_ID
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID IS NOT null
    GROUP BY DEPARTMENT_ID
    HAVING AVG(MONTHS_BETWEEN(SYSDATE, HIRE_DATE)/12)>5
)
AND J.MAX_SALARY>(
    SELECT AVG(MAX_SALARY)
    FROM JOBS
)
ORDER BY J.JOB_TITLE;

-- Find employees who earn more than their department's 
--average salary but do NOT work in
-- departments with more than 5 employees.

SELECT EMPLOYEE_ID,
e.first_name || ' ' || e.last_name AS full_name,
       d.department_name,
       e.salary
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON D.DEPARTMENT_ID=E.DEPARTMENT_ID
WHERE E.SALARY>(
    SELECT AVG(E2.SALARY)
    FROM EMPLOYEES E2 
    WHERE E2.DEPARTMENT_ID=E.DEPARTMENT_ID
)
AND (
    SELECT COUNT(*)
    FROM EMPLOYEES E3 
    WHERE E3.DEPARTMENT_ID=E.DEPARTMENT_ID
)<=5
ORDER BY D.DEPARTMENT_NAME, E.SALARY DESC;


-- Write a SQL query to find employees 
-- from the USA who have a manager (using EXISTS), 
-- no job_history records (using NOT EXISTS), and salary greater
--  than their department average. Display full_name, salary, and use
--   a CASE statement to label 'USA Star' if salary > 1.4 times
-- department average, otherwise 'USA Above'.

SELECT E.FIRST_NAME || ' ' || E.LAST_NAME AS full_name,
E.SALARY,
CASE 
    WHEN E.SALARY>1.4*(
        SELECT AVG(E4.SALARY)
        FROM EMPLOYEES E4 
        WHERE E4.DEPARTMENT_ID=E.DEPARTMENT_ID
    )
    THEN 'USA STAR'
    ELSE 'USA ABOVE'
    END AS SALARY_STATUS
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
JOIN LOCATIONS L 
ON D.LOCATION_ID=L.LOCATION_ID
WHERE L.COUNTRY_ID='US'
AND E.MANAGER_DI IS NOT NULL 
AND EXISTS(
    SELECT 1
    FROM EMPLOYEES E2
    WHERE E2.EMPLOYEE_ID=E.MANAGER_ID
)
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
ORDER BY E.SALARY DESC;


-- Write an SQL query to list all departments 
-- where every employee earns more than 5000. For each
-- department, display the department name, the number of 
-- employees in that department, and a
-- column called Salary_Level that uses a CASE 
-- statement to show 'Above' if the department’s
-- average salary is higher than the overall company average
--  salary, or 'Below or Equal' if it is not.

SELECT D.DEPARTMENT_NAME, COUNT(E.EMPLOYEE_ID) AS EMPLOYEE_CNT,
CASE 
    WHEN(
        AVG(E.SALARY)>(
            SELECT AVG(SALARY)
            FROM EMPLOYEES
        )
    )THEN 'ABOVE'
    ELSE 'BELLOW OR EQUAL'
    END AS SALARY_LEVEL
FROM DEPARTMENTS D 
JOIN EMPLOYEES E 
ON D.DEPARTMENT_ID=E.DEPARTMENT_ID 
GROUP BY D.DEPARTMENT_ID, D.DEPARTMENT_NAME
HAVING MIN(E.SALARY)>5000
ORDER BY D.DEPARTMENT_NAME;



-- Write an SQL query to find employees who earn more 
-- than the highest salary of at least one other
-- department. Only include employees whose department 
-- has at least 3 employees and who do not
-- have any records in the JOB_HISTORY table. For each
--  qualifying employee, display the
-- employee ID, full name, department name, and salary.

SELECT E.EMPLOYEE_ID, E.FIRST_NAME||' '||E.LAST_NAME AS FULL_NAME,
E.DEPARTMENT_ID, D.DEPARTMENT_NAME, E.salary
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
WHERE E.SALARY>ANY(
    SELECT MAX(E2.SALARY)
    FROM EMPLOYEES E2
    WHERE E2.DEPARTMENT_ID<>E.DEPARTMENT_ID
    AND E2.DEPARTMENT_ID IS NOT null
    GROUP BY E2.DEPARTMENT_ID
)
AND E.DEPARTMENT_ID IN(
    SELECT E3.DEPARTMENT_ID 
    FROM EMPLOYEE E3 
    WHERE E3.DEPARTMENT_ID IS NOT null
    GROUP BY E3.DEPARTMENT_ID
    HAVING COUNT(*)>=3
)
AND NOT EXISTS(
    SELECT 1
    FROM JOB_HISTORY JH 
    WHERE JH.EMPLOYEE_ID=E.EMPLOYEE_ID
)
ORDER BY E.SALARY DESC;

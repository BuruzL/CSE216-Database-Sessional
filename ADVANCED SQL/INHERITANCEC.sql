-- 1. Find employees earning above their
--  department's average salary in departments with more than 4
-- employees.

SELECT E.EMPLOYEE_ID,  E.FIRST_NAME || ' ' || E.LAST_NAME AS FULL_NAME,
E.SALARY, E.DEPARTMENT
FROM EMPLOYEE E 
JOIN DEPARTMENT D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
WHERE E.SALARY>(
    SELECT AVG(E2.SALARY)
    FROM EMPLOYEE E2
    WHERE E2.EMPLOYEE_ID=E.EMPLOYEE_ID
)
AND E.EMPLOYEE_ID IN (
    SELECT E3.EMPLOYEE_ID
    FROM EMPLOYEE E3
    WHERE E3.DEPARTMENT_ID IS NOT NULL
    GROUP BY E3.DEPARTMENT_ID 
    HAVING COUNT(*)>4
);

--THE SOLUTION BELLOW MAY OR MAY NOT BE THE BEST SOLUTION, i AM TALKING ABOUT QUES 2
-- 2. Find employees who either earn more than their 
-- manager's salary or have a salary greater than
-- their department's average salary. Print employee 
-- details with the type as either "Higher Than
-- Manager" or "Above Dept Avg".

SELECT E.EMPLOYEE_ID, D.DEPARTMENT_NAME, 
E.DEPARTMENT_ID, E.SALARY,  E.FIRST_NAME || ' ' || E.LAST_NAME AS FULL_NAME,
CASE
     WHEN E.SALARY>(
    SELECT M.SALARY
    FROM EMPLOYEES M 
    WHERE M.EMPLOYEE_ID=E.MANAGER_ID
) THEN 'HIGHER THAN MANAGER'
WHEN E.SALARY>(
    SELECT AVG(E2.SALARY)
    FROM EMPLOYEES E2 
    WHERE E.DEPARTMENT_ID=E2.DEPARTMENT_ID
) THEN 'ABOVE AVG DEPT'
END AS SAL_TYPE

FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
WHERE E.SALARY>(
    SELECT AVG(E2.SALARY)
    FROM EMPLOYEES E2 
    WHERE E.DEPARTMENT_ID=E2.DEPARTMENT_ID
)
OR E.SALARY>(
    SELECT M.SALARY
    FROM EMPLOYEES M 
    WHERE M.EMPLOYEE_ID=E.MANAGER_ID
)
ORDER BY E.EMPLOYEE_ID;

-- 3. Write a SQL query for employees whose salary 
-- beats their department average and whose
-- manager's salary beats the company average. Show full_name, 
-- salary, department_name, and
-- label it 'Dept Top Earner' if salary > 1.5 times dept average, 
-- else 'Dept Above Avg'.

SELECT E.FIRST_NAME||' '||E.LAST_NAME AS FULL_NAME,
E.SALARY, D.DEPARTMENT_NAME,
CASE
    WHEN
        E.SALARY>1.5*(
             SELECT AVG(E3.SALARY)
        FROM EMPLOYEES E3 
        WHERE E.DEPARTMENT_ID=E3.DEPARTMENT_ID
        ) THEN 'DEPT TOP EARNER'
        ELSE 'DEPT ABOVE AVG'
        END AS EMP_LABEL
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON D.DEPARTMENT_ID=E.DEPARTMENT_ID
WHERE E.SALARY>(
    SELECT AVG(E4.SALARY)
    FROM EMPLOYEES E4 
    WHERE E.DEPARTMENT_ID=E4.DEPARTMENT_ID
)
AND(
    (SELECT M.SALARY
    FROM EMPLOYEES M 
    WHERE M.EMPLOYEE_ID=E.MANAGER_ID)>(
        SELECT AVG(E3.SALARY)
        FROM EMPLOYEES E3 
    )
)
ORDER BY E.EMPLOYEE_ID DESC;


-- 4. Find employee_id, full name, and department 
-- name of employees whose department is located in
-- the same city as their manager’s department.

SELECT E.EMPLOYEE_ID, E.FIRST_NAME|| ' ' ||E.LAST_NAME AS FULL_NAME,
D.DEPARTMENT_NAME
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON D.DEPARTMENT_ID=E.DEPARTMENT_ID 
JOIN LOCATIONS L 
ON L.LOCATION_ID=D.LOCATION_ID
WHERE(
    L.CITY=(
        SELECT LL.CITY
        FROM EMPLOYEES M
JOIN DEPARTMENTS DD 
ON DD.DEPARTMENT_ID=M.DEPARTMENT_ID 
JOIN LOCATIONS LL 
ON LL.LOCATION_ID=DD.LOCATION_ID
WHERE E.MANAGER_ID=M.EMPLOYEE_ID
    )
)
ORDER BY E.EMPLOYEE_ID DESC;

-- 5. Write an SQL query to list all departments that 
-- satisfy the following conditions:
-- (i) every employee in the department earns more than 5000,
-- (ii) the department has at least one employee with job history,
--  and
-- (iii) the maximum salary in the department is greater than the 
-- overall company average salary.
-- For each such department, display the department name, number 
-- of employees, average salary, and a
-- column called Salary_Level that shows
-- ● 'Elite' if the department’s average salary is greater than
--  1.5 times the company average salary,
-- ● 'Above Average' otherwise.

SELECT D.DEPARTMENT_NAME, COUNT(EMPLOYEE_ID) AS NUM_OF_EMP,
AVG(SALARY) AS AVG_SAL,
CASE 
    when
    AVG(E.SALARY)>1.5*(
        SELECT AVG(E4.SALARY)
        FROM EMPLOYEES E4
    )THEN 'ELITE'
    ELSE 'ABOVE AVERAGE'
    END AS SALARY_LEVEL
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
WHERE EXISTS (
    SELECT 1
    FROM EMPLOYEES E2 
    JOIN JOB_HISTORY JH 
    ON JH.EMPLOYEE_ID=E2.EMPLOYEE_ID
    WHERE E2.DEPARTMENT_ID=D.DEPARTMENT_ID
)
GROUP BY D.DEPARTMENT_ID,
D.DEPARTMENT_NAME
HAVING MIN(E.SALARY)>5000
AND MAX(E.SALARY)>(
    SELECT AVG(E3.SALARY)
    FROM EMPLOYEES E3
);

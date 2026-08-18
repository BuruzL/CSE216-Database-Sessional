--6.2
--a a. Find those employees whose salary is higher than at least three other employees. Print last
-- names and salary of each employee. You cannot use join in the main query. Use sub-query in
-- WHERE clause only. You can use join in the sub-queries.
SELECT E.LAST_NAME, E.SALARY
FROM EMPLOYEES E 
WHERE (
    SELECT COUNT(*)
    FROM EMPLOYEES E2
    WHERE E.SALARY>E2.SALARY
)>=3;

--b. Find those departments whose average salary is greater than the minimum salary of all other
--departments. Print department names. Use sub-query. You can use join in the sub-queries.
SELECT D.DEPARTMENT_NAME
FROM DEPARTMENTS D 
WHERE(
    SELECT AVG(E.SALARY)
    FROM EMPLOYEES E
    WHERE E.DEPARTMENT_ID=D.DEPARTMENT_ID
)>ALL(
    SELECT MIN(E2.SALARY)
    FROM EMPLOYEES E2
    WHERE E.DEPARTMENT_ID<>E2.DEPARTMENT_ID
    GROUP BY E2.DEPARTMENT_ID
);

--c. Find those department names which have the highest number of employees in service. Print
--department names. Use sub-query. You can use join in the sub-queries.
SELECT D.DEPARTMENT_NAME
FROM DEPARTMENTS D 
WHERE(
    SELECT COUNT(*)
    FROM EMPLOYEES E 
    WHERE E.DEPARTMENT_ID=D.DEPARTMENT_ID 
)>=ALL(
    SELECT COUNT(*)
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
);


--d. Find those employees who worked in more than one department in the company. Print
-- employee last names. You cannot use join in the main query. Use sub-query. You can use join
-- in the sub-queries.
SELECT E.LAST_NAME
FROM EMPLOYEES E 
WHERE EXISTS (
    SELECT *
    FROM JOB_HISTORY O 
    WHERE O.EMPLOYEE_ID=E.EMPLOYEE_ID
    AND E.DEPARTMENT_ID<>O.DEPARTMENT_ID
);

--e
--For each employee, find the minimum and maximum salary of his/her department. Print
-- employee last name, minimum salary, and maximum salary. Do not use sub-query in WHERE
-- clause. Use sub-query in FROM clause.
SELECT E.LAST_NAME, D.MINSAL, D.MAXSAL
FROM EMPLOYEES E, (
    SELECT DEPARTMENT_ID, MIN(SALARY) AS MINSAL, MAX(SALARY) AS MAXSAL
    FROM EMPLOYEES 
    GROUP BY DEPARTMENT_ID
) D
WHERE E.DEPARTMENT_ID=D.DEPARTMENT_ID
ORDER BY E.SALARY;


--f. For each job type, find the employee who gets the highest salary. Print job title and last name
--of the employee. Assume that there is one and only one such employee for every job type.
SELECT J.JOB_TITLE, E.LAST_NAME
FROM EMPLOYEES E 
JOIN JOBS J 
ON E.JOB_ID=J.JOB_ID
WHERE E.SALARY=(
    SELECT MAX(M.SALARY)   
     FROM EMPLOYEES M 
    WHERE E.JOB_ID=M.JOB_ID
);




-- --QUESTIONS
-- a. For each employee print last name, salary, and job title.
-- b. For each department, print department name and country name it is situated in.
-- c. For each country, finds total number of departments situated in the country.
-- d. For each employee, finds the number of job switches of the employee.
-- e. For each department and job types, find the total number of employees working. Print
-- department names, job titles, and total employees working.
-- f. For each employee, finds the total number of employees those were hired before him/her. Print
-- employee last name and total employees.
-- g. For each employee, finds the total number of employees those were hired before him/her and
-- those were hired after him/her. Print employee last name, total employees hired before him,
-- and total employees hired after him.
-- h. Find the employees having salaries greater than at least three other employees
-- i. For each employee, find his rank, i.e., position with respect to salary. The highest salaried
-- employee should get rank 1 and lowest salaried employee should get the last rank. Employees
-- with same salary should get same rank value. Print employee last names and his/he rank.
-- j. Finds the names of employees and their salaries for the top three highest salaried employees.
-- The number of employees in your output should be more than three if there are employees with
-- same salary.



--a
SELECT E.LAST_NAME, E.SALARY, J.JOB_TITLE
FROM EMPLOYEES E 
JOIN JOBS J 
ON E.JOB_ID=J.JOB_ID;

--b
SELECT D.DEPARTMENT_NAME, C.COUNTRY_NAME
FROM DEPARTMENTS D 
join LOCATIONS L 
ON D.LOCATION_ID=L.LOCATION_ID
JOIN COUNTRIES C 
ON L.COUNTRY_ID=C.COUNTRY_ID;

--c
SELECT  C.COUNTRY_NAME, COUNT(D.DEPARTMENT_ID)
FROM DEPARTMENTS D 
JOIN LOCATIONS L 
ON L.LOCATION_ID=D.LOCATION_ID 
JOIN COUNTRIES C 
ON L.COUNTRY_ID=C.COUNTRY_ID
GROUP BY C.COUNTRY_NAME;

--d
SELECT E.EMPLOYEE_ID, COUNT(J.START_DATE)
FROM EMPLOYEES E 
LEFT JOIN JOB_HISTORY J 
ON E.JOB_ID=J.EMPLOYEE_ID
GROUP BY E.EMPLOYEE_ID;

--e
SELECT J.JOB_TITLE, COUNT(E.EMPLOYEE_ID), D.DEPARTMENT_NAME
FROM EMPLOYEES E 
JOIN JOBS J 
ON E.JOB_ID=J.JOB_ID 
JOIN DEPARTMENTS D
ON E.DEPARTMENT_ID=D.DEPARTMENT_ID
GROUP BY J.JOB_TITLE, D.DEPARTMENT_NAME;

--f
SELECT E.LAST_NAME, COUNT(O.EMPLOYEE_ID)
FROM EMPLOYEES E 
JOIN EMPLOYEES O 
ON E.HIRE_DATE>O.HIRE_DATE
GROUP BY E.LAST_NAME;

--g
SELECT E.LAST_NAME , COUNT(E1.EMPLOYEE_ID) AS BEFORE, 
COUNT(E2.EMPLOYEE_ID)AS AFTER
FROM EMPLOYEES E 
JOIN EMPLOYEES E1 
ON E.HIRE_DATE>E1.HIRE_DATE
JOIN EMPLOYEES E2 
ON E.HIRE_DATE<E2.HIRE_DATE
GROUP BY E.LAST_NAME;

--h
SELECT E.EMPLOYEE_ID
FROM EMPLOYEES E 
WHERE (
    SELECT COUNT(O.EMPLOYEE_ID)
    FROM EMPLOYEES O 
    WHERE E.SALARY>O.SALARY
) >=3;


--THE PROBLEMS BELLOW ARE QUITE TRICKY
--i
SELECT LAST_NAME,
RANK() OVER (ORDER BY SALARY DESC) AS SALARY_RANK
FROM EMPLOYEES;

--WITHOUT RANK FUNCTION
SELECT E.LAST_NAME,
1+(
    SELECT COUNT(*)
    FROM EMPLOYEES E2
    WHERE E2.SALARY>E.SALARY
)AS SALARY_RANK
FROM EMPLOYEES E
ORDER BY E.SALARY DESC;


--j
SELECT LAST_NAME, SALARY
FROM EMPLOYEES E
WHERE (
    SELECT COUNT(DISTINCT SALARY)
    FROM EMPLOYEES 
    WHERE SALARY>E.SALARY
)<3;

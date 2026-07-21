-- Practice Question

-- Using the Oracle HR schema, find the employee_id, full_name, salary, department_name, job_title, and city of employees who satisfy all the following conditions:

-- Their JOB_ID is performed by at least one employee in either London or Toronto.
-- Their JOB_ID is not performed by any employee in Seattle.
-- Their salary is greater than the average salary of their own department.
-- Employees without a department must not be included.

-- Use:

-- UNION to find jobs performed in London or Toronto.
-- MINUS to remove jobs performed in Seattle.
-- Joins between EMPLOYEES, DEPARTMENTS, LOCATIONS, and JOBS.
-- A correlated subquery to compare each employee’s salary with their department average.

-- Display the results in descending order of salary. For equal salaries, display the employee with the lower employee_id first.



SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.SALARY,
D.DEPARTMENT_NAME, J.JOB_TITLE, L.CITY
FROM EMPLOYEES E 
JOIN DEPARTMENTS D 
ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN JOBS J
ON E.JOB_ID = J.JOB_ID
JOIN LOCATIONS L 
ON L.LOCATION_ID = D.LOCATION_ID
WHERE E.JOB_ID IN (
    SELECT E1.JOB_ID
    FROM EMPLOYEES E1
    JOIN DEPARTMENTS D1
    ON E1.DEPARTMENT_ID = D1.DEPARTMENT_ID
    JOIN LOCATIONS L1
    ON L1.LOCATION_ID = D1.LOCATION_ID
    WHERE UPPER(L1.CITY) = 'LONDON'

    UNION 

    SELECT E2.JOB_ID
    FROM EMPLOYEES E2
    JOIN DEPARTMENTS D2
    ON E2.DEPARTMENT_ID = D2.DEPARTMENT_ID
    JOIN LOCATIONS L2
    ON L2.LOCATION_ID = D2.LOCATION_ID
    WHERE UPPER(L2.CITY) = 'TORONTO'

    MINUS 

    SELECT E3.JOB_ID
    FROM EMPLOYEES E3
    JOIN DEPARTMENTS D3
    ON E3.DEPARTMENT_ID = D3.DEPARTMENT_ID
    JOIN LOCATIONS L3
    ON L3.LOCATION_ID = D3.LOCATION_ID
    WHERE UPPER(L3.CITY) = 'SEATTLE'
)
AND E.SALARY > (
    SELECT AVG(E4.SALARY)
    FROM EMPLOYEES E4
    WHERE E.DEPARTMENT_ID = E4.DEPARTMENT_ID
)
ORDER BY E.SALARY DESC,
E.EMPLOYEE_ID ASC;

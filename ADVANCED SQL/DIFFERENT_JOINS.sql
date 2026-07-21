-- Question — Oracle HR Schema: LEFT OUTER JOIN

-- Find all departments that currently have no employees.

-- Display:

-- DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, and EMPLOYEE_COUNT.

-- The EMPLOYEE_COUNT should display 0 for every department returned. Sort the result by DEPARTMENT_NAME in ascending order.

-- Do not use NOT IN, NOT EXISTS, or set operators. Solve the problem using a LEFT OUTER JOIN and a NULL check.

-- This follows the slide’s method of using a left outer join to retain unmatched rows from the left table.

SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, D.MANAGER_ID , 
COUNT(EMPLOYEE_ID)
FROM DEPARTMENTS D 
LEFT OUTER JOIN EMPLOYEES E 
ON D.DEPARTMENT_ID=E.DEPARTMENT_ID
GROUP BY 
D.DEPARTMENT_ID, D.DEPARTMENT_NAME, D.MANAGER_ID
HAVING COUNT(E.EMPLOYEE_ID)=0
ORDER BY D.DEPARTMENT_NAME ASC;



-- Question — Oracle HR Schema: RIGHT OUTER JOIN

-- Find all jobs, including jobs to which no employee is currently assigned.

-- Display:

-- JOB_ID, JOB_TITLE, EMPLOYEE_ID, FULL_NAME, SALARY, and ASSIGNMENT_STATUS.

-- Use a CASE expression to show:

-- 'Assigned' when an employee is assigned to the job;
-- 'No Employee Assigned' when the job has no employee.

-- Use a RIGHT OUTER JOIN, placing EMPLOYEES on the left and JOBS on the right. Sort the output so that jobs with no employees appear first, followed by assigned jobs. Within each group, sort by JOB_TITLE and then EMPLOYEE_ID in ascending order.

-- A right outer join keeps all matching rows and all unmatched rows from the right-side table. The question follows the multi-condition Oracle HR-schema style of the supplied exercise sheet.

SELECT J.JOB_ID, J.JOB_TITLE, E.EMPLOYEE_ID, E.FIRST_NAME, E.SALARY,
CASE
    WHEN J.JOB_ID IS NOT NULL 
    AND E.EMPLOYEE_ID IS NULL  
    THEN 'NO EMPLOYEE ASSIGNED'

    WHEN J.JOB_ID IS NOT NULL
    AND E.EMPLOYEE_ID IS NOT NULL   
    THEN 'ASSIGNED'
    END AS ASSIGNMENT_STATUS   
FROM EMPLOYEES E 
RIGHT OUTER JOIN JOBS J 
ON E.JOB_ID=J.JOB_ID 
ORDER BY 
CASE 
    WHEN E.EMPLOYEE_ID IS NULL THEN 1
    ELSE 2
    END, 
    J.JOB_TITLE ASC,
    E.EMPLOYEE_ID ASC;




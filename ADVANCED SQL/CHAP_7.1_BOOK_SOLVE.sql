-- --7.1 a
-- a. Find EMPLOYEE_ID of those employees who are not managers. Use minus operator to
-- perform this.
SELECT EMPLOYEE_ID
FROM EMPLOYEES E 
MINUS 
SELECT M.MANAGER_ID
FROM EMPLOYEES M 
WHERE M.MANAGER_ID IS NOT NULL;


-- b. Find last names of those employees who are not managers. Use minus operator to perform this.
SELECT LAST_NAME
FROM EMPLOYEES 
minus
SELECT LAST_NAME
FROM EMPLOYEES 
WHERE EMPLPOYEE_ID IN(
    SELECT MANAGER_ID
    FROM EMPLOYEES 
    WHERE MANAGER_ID IS NOT NULL
);

-- c. Find the LOCATION_ID of those locations having no departments.
SELECT LOCATION_ID
FROM LOCATIONS
minus
SELECT LOCATION_ID
FROM DEPARTMENTS
WHERE LOCATION_ID IS NOT NULL;

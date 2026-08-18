--6.1
--a. Find the last names of all employees that work in the SALES department.
SELECT LAST_NAME
FROM EMPLOYEES
WHERE DEPARTMENT_ID=(
    SELECT DEPARTMENT_ID
    FROM DEPARTMENTS
    WHERE DEPARTMENT_NAME='Sales'
);

--b.Find the last names and salaries of those employees who get higher salary than at least one
-- employee of SALES department.
SELECT LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY> ANY(
    SELECT SALARY
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID=(
        SELECT DEPARTMENT_ID
        FROM DEPARTMENTS
        WHERE DEPARTMENT_NAME='Sales'
    )
);

--c. Find the last names and salaries of those employees whose salary is higher than all employees
--of SALES department.
SELECT LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY> ALL(
    SELECT SALARY
    FROM EMPLOYEES
     WHERE DEPARTMENT_ID = (
        SELECT DEPARTMENT_ID
        FROM DEPARTMENTS
        WHERE DEPARTMENT_NAME = 'Sales'
    )
);

--d. Find the last names and salaries of those employees whose salary is within ± 5k of the average
--salary of SALES department.
SELECT LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY BETWEEN (
    SELECT AVG(SALARY)-5000
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID(
        SELECT DEPARTMENT_ID
        FROM DEPARTMENTS
        WHERE DEPARTMENT_NAMES='Sales'
    )
) AND (
    SELECT AVG(SALARY)+5000
    FROM EMPLOYEES
     WHERE DEPARTMENT_ID(
        SELECT DEPARTMENT_ID
        FROM DEPARTMENTS
        WHERE DEPARTMENT_NAMES='Sales'
    )
);


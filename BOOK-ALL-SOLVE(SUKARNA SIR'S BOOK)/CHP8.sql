-- a. Update COMMISSION_PCT value to 0 for those employees who have NULL in that column.
-- b. Update salary of all employees to the maximum salary of the department in which he/she
-- works.
-- c. Update COMMISSION_PCT to N times for each employee where N is the number of
-- employees he/she manages. When N = 0, keep the old value of COMMISSION_PCT column.
-- d. Update the hiring dates of all employees to the first day of the same year. Do not change this
-- for those employees who joined on or after year 2000.

-- a. Replace NULL commission percentages with 0
UPDATE employees
SET commission_pct = 0
WHERE commission_pct IS NULL;


-- b. Set each employee's salary to the maximum salary in their department
UPDATE employees e
SET salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);


-- c. Multiply COMMISSION_PCT by the number of employees directly managed.
-- Employees managing nobody retain their existing value.
UPDATE employees e
SET commission_pct = commission_pct * (
    SELECT COUNT(*)
    FROM employees subordinate
    WHERE subordinate.manager_id = e.employee_id
)
WHERE EXISTS (
    SELECT 1
    FROM employees subordinate
    WHERE subordinate.manager_id = e.employee_id
);


-- d. Change pre-2000 hire dates to January 1 of the same year
UPDATE employees
SET hire_date = TRUNC(hire_date, 'YEAR')
WHERE hire_date < DATE '2000-01-01';

COMMIT;


-- a. Delete those employees who earn less than 5k.
-- b. Delete those locations having no departments.
-- c. Delete those employees from the EMPLOYEES table who joined before the year 1997.


-- a. Delete employees earning less than 5,000
DELETE FROM employees
WHERE salary < 5000;


-- b. Delete locations that have no departments
DELETE FROM locations l
WHERE NOT EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.location_id = l.location_id
);


-- c. Delete employees who joined before 1997
DELETE FROM employees
WHERE hire_date < DATE '1997-01-01';

COMMIT;

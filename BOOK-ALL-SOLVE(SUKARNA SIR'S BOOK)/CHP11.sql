--CHAPTER 11.3 (11.1 AND 11.2 ER QUESTIONS TO BOI E DEKHI NA)

--a

-- Calculate the number of employees in different salary grades for each department using
-- COUNT aggregation function instead of SUM.
SELECT DEPARTMENT_ID,
COUNT(CASE WHEN SALARY<5000 THEN 1 END) AS "C",
COUNT(CASE WHEN SALARY>=5000 AND SALARY<15000 THEN 1 END)AS "B",
COUNT(CASE WHEN SALARY>=15000 AND SALARY<20000 THEN 1 END)AS "A"
FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID;


--b

-- b. Calculate the number of employees in different salary grades for each department using
-- DECODE instead of CASE.
SELECT DEPARTMENT_ID,

       -- Grade C: Salary < 5000
       SUM(
           DECODE(SIGN(SALARY - 5000),
                  -1, 1,
                  0)
       ) AS "C",

       -- Grade B: Salary >= 5000 AND Salary < 10000
       SUM(
           DECODE(SIGN(SALARY - 5000),
                  -1, 0,
                  DECODE(SIGN(SALARY - 10000),
                         -1, 1,
                         0))
       ) AS "B",

       -- Grade A: Salary >= 10000
       SUM(
           DECODE(SIGN(SALARY - 10000),
                  -1, 0,
                  1)
       ) AS "A"

FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
ORDER BY DEPARTMENT_ID;

-- c. Write the query to show total employees working in the employee’s department and in the
-- employee’s manager’s department without using WITH clause. You can use subqueries in the
-- FROM clause.
SELECT E.EMPLOYEE_ID, E2.EMPCNT, M2.EMPCNT
FROM (
    SELECT DEPARTMENT_ID, COUNT(*) AS EMPCNT
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
)E2, EMPLOYEES E,(
    SELECT DEPARTMENT_ID, COUNT(*) AS EMPCNT
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
)M2, EMPLOYEES M
WHERE E.DEPARTMENT_ID=E2.DEPARTMENT_ID
AND E.MANAGER_ID=M.EMPLOYEE_ID
AND M.DEPARTMENT_ID=M2.DEPARTMENT_ID;

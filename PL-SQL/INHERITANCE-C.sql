-- 1. Write a PL/SQL trigger that will enforce the following business rule:
-- The total salary paid to all employees in any single department must never exceed
-- $50,000 after any salary modification.
CREATE OR REPLACE TRIGGER SAL_TRIG 
after INSERT OR UPDATE 
OF SALARY, DEPARTMENT_ID 
ON EMPLOYEES 
DECLARE 
V_COUNT NUMBER;
TOT_SAL NUMBER;
INVAL EXCEPTION;
BEGIN 
  SELECT COUNT(*)
  INTO V_COUNT 
  FROM EMPLOYEES E 
  WHERE (
    SELECT SUM(E2.SALARY)
    FROM EMPLOYEES E2 
    WHERE E2.DEPARTMENT_ID=E.DEPARTMENT_ID
  )>50000;
  IF V_COUNT>0 THEN 
  RAISE INVAL;
  END IF;
EXCEPTION 
WHEN INVAL THEN 
DBMS_OUTPUT.PUT_LINE('JHAMELA ASE');
END;
/

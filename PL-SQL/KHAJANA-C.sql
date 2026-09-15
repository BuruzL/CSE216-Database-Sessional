CREATE TABLE DEPT_PAYROLL_SUMMARY (
COUNTRY_ID VARCHAR2(2),
DEPARTMENT_ID NUMBER,
DEPARTMENT_NAME VARCHAR2(30),
CITY VARCHAR2(30),
MONTHLY_PAYROLL NUMBER,
PAYROLL_BAND VARCHAR2(10),
GENERATED_BY VARCHAR2(30),
GENERATED_ON DATE
);


--FUNCTION
CREATE OR REPLACE FUNCTION GET_DEPT_PAYROLL(
    P_DEPT_ID IN NUMBER
)RETURN NUMBER IS 
--VAR
V_TOTAL_COST NUMBER;
V_EMP_CNT NUMBER;
BEGIN 
    BEGIN 
        SELECT COUNT(*)
        INTO V_EMP_CNT 
        FROM EMPLOYEES 
        WHERE DEPARTMENT_ID=P_DEPT_ID;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
        RETURN -1;
    END;
    IF V_EMP_CNT=0 THEN
    RETURN 0;
    END IF;

    V_TOTAL_COST:=0;

    FOR EMP_REC IN (
        SELECT E.EMPLOYEE_ID, E.SALARY 
        FROM EMPLOYEES E
        WHERE E.DEPARTMENT_ID=P_DEPT_ID
    )LOOP 
        V_TOTAL_COST:=V_TOTAL_COST+EMP_REC.SALARY*(EMP_REC.COMMISSION_PCT+1);
      END LOOP;
      RETURN V_TOTAL_COST;  
END GET_DEPT_PAYROLL;
/


--PROCEDURE 
CREATE OR REPLACE PROCEDURE BUILD_COUNTRY_PAYROLL (
P_COUNTRY_ID IN VARCHAR2,
P_STAFFED_DEPTS OUT NUMBER,
P_TOTAL_PAYROLL OUT NUMBER,
P_TOP_DEPT_ID OUT NUMBER
) IS 
--VARS
V_PAYROLL NUMBER;
BAND VARCHAR2;
PREV_PAYROLL NUMBER;
BEGIN 
    DELETE DEPT_PAYROLL_SUMMARY
    WHERE COUNTRY_ID=P_COUNTRY_ID;

    P_STAFFED_DEPTS:=0;
    P_TOTAL_PAYROLL:=0;
    P_TOP_DEPT_ID:=0;
    PREV_PAYROLL:=0;

    FOR DEPT_INFO IN (
        SELECT C.COUNTRY_ID,
        D.DEPARTMENT_ID,
        D.DEPARTMENT_NAME,
        L.CITY
        FROM DEPARTMENTS D 
        JOIN LOCATIONS L 
        ON D.LOCATION_ID=L.LOCATION_ID 
        JOIN COUNTRIES C 
        ON L.COUNTRY_ID=C.COUNTRY_ID 
        WHERE C.COUNTRY_ID=P_COUNTRY_ID
    )loop
    V_PAYROLL:=GET_DEPT_PAYROLL(DEPT_INFO.DEPARTMENT_ID);
    P_TOTAL_PAYROLL:=P_TOTAL_PAYROLL+V_PAYROLL;
    IF(V_PAYROLL>PREV_PAYROLL)then
    P_TOP_DEPT_ID:=DEPT_INFO.DEPARTMENT_ID;
    PREV_PAYROLL:=V_PAYROLL;
    ELSIF V_PAYROLL=PREV_PAYROLL
    --SMALLER DEPT ID
    END IF;

    IF V_PAYROLL=0 THEN
    BAND:='EMPTY';
    P_STAFFED_DEPTS:=P_STAFFED_DEPTS+1;
    ELSIF V_PAYROLL<=25000 THEN 
    BAND:='SMALL';
    ELSIF V_PAYROLL<=100000 THEN 
    BAND:='MEDIUM';
    ELSE 
    BAND:='LARGE';
    END IF;

    INSERT INTO DEPT_PAYROLL_SUMMARY(
        COUNTRY_ID,
        DEPARTMENT_ID,
        DEPARTMENT_NAME,
        CITY,
        MONTHLY_PAYROLL,
        PAYROLL_BAND, 
        GENERATED_BY,
        GENERATED_ON 
    )VALUES(
       P_COUNTRY_ID,
       DEPT_INFO.DEPARTMENT_ID,
       DEPT_INFO.DEPARTMENT_NAME,
       DEPT_INFO.CITY,
       V_PAYROLL,
       BAND,
       USER,
       SYSDATE 
    );
    END LOOP;
END;
/

SET SERVEROUTPUT ON;
DECLARE 
P_STAFFED_DEPTS NUMBER,
P_TOTAL_PAYROLL NUMBER,
P_TOP_DEPT_ID NUMBER
BEGIN 
    BUILD_COUNTRY_PAYROLL('US', P_STAFFED_DEPTS,P_TOTAL_PAYROLL,
    P_TOP_DEPT_ID);
 DBMS_OUTPUT.PUT_LINE( P_STAFFED_DEPTS || P_TOTAL_PAYROLL||  P_TOP_DEPT_ID);
  BUILD_COUNTRY_PAYROLL('IT', P_STAFFED_DEPTS,P_TOTAL_PAYROLL,
    P_TOP_DEPT_ID);
 DBMS_OUTPUT.PUT_LINE( P_STAFFED_DEPTS || P_TOTAL_PAYROLL||  P_TOP_DEPT_ID);
END;
/




--2. Whenever somebody changes the SALARY column of EMPLOYEES, two things must
-- happen automatically:

-- ● The value is silently corrected (you have not been taught to raise your own
-- errors, so never reject the statement — fix the value, the way the class fixed a
-- name with INITCAP):
-- ○ No pay cuts — if the new salary is lower than the old one, keep the old
-- salary.
-- ○ Job ceiling — the salary may not exceed MAX_SALARY of that employee's
-- job. Look MAX_SALARY up from JOBS; if the new salary is above it, store
-- MAX_SALARY instead.

-- ● Every effective change is logged into SALARY_CHANGE_LOG — old salary, the
-- final new salary (after correction), the percentage change rounded to 2 decimals,
-- the database user, and the time. If, after the correction, the salary did not actually
-- change, write no row.
-- Task
-- ● Create the SALARY_CHANGE_LOG table.
-- ● Create the trigger(s) on EMPLOYEES.
-- ● Show it working with four UPDATEs (see the driver below).

-- Test driver and verified output

-- Employees 103 / 104 / 105 / 106 are all IT_PROG (MAX_SALARY = 10000) with salaries
-- 9000 / 6000 / 4800 / 4800.
-- UPDATE EMPLOYEES SET SALARY = SALARY + 200 WHERE EMPLOYEE_ID = 104;
-- -- in band
-- UPDATE EMPLOYEES SET SALARY = 50000 WHERE EMPLOYEE_ID = 105;
-- -- clamps to 10000
-- UPDATE EMPLOYEES SET SALARY = 1 WHERE EMPLOYEE_ID = 106;
-- -- pay cut -> blocked
-- UPDATE EMPLOYEES SET SALARY = 20000 WHERE EMPLOYEE_ID = 103;

-- -- clamps to 10000
-- UPDATE EMPLOYEES SET SALARY = 15000 WHERE EMPLOYEE_ID = 103;
-- -- already at ceiling
-- SELECT EMPLOYEE_ID, OLD_SALARY, NEW_SALARY, PCT_CHANGE
-- FROM SALARY_CHANGE_LOG
-- ORDER BY CHANGED_ON, EMPLOYEE_ID;
-- ROLLBACK;
-- Resulting salaries: 103 -> 10000, 104 -> 6200, 105 -> 10000, 106 -> 4800 (unchanged).
-- SALARY_CHANGE_LOG — exactly three rows:
-- EMPLOYEE_ID OLD_SALARY NEW_SALARY PCT_CHANGE
-- 104 6000 6200 3.33
-- 105 4800 10000 108.33
-- 103 9000 10000 11.11

-- ● Employee 106 writes no row: the BEFORE trigger restores 4800, so the AFTER trigger's
-- :NEW.SALARY <> :OLD.SALARY test is false.
-- ● The second update of employee 103 writes no row either: 103 is already at the 10000
-- ceiling, so the clamp leaves :NEW.SALARY = :OLD.SALARY.

CREATE TABLE SALARY_CHANGE_LOG(
    EMPLOYEE_ID NUMBER,
    OLD_SALARY NUMBER,
    NEW_SALARY NUMBER,
    PCT_CHANGE NUMBER
);
CREATE OR REPLACE TRIGGER SAL_CORRECTION_TRIG
BEFORE UPDATE OF SALARY
ON EMPLOYEES
FOR EACH ROW
DECLARE
    V_OLD_SAL NUMBER;
    V_NEW_SAL NUMBER;
    J_MAX     NUMBER;
BEGIN
    V_OLD_SAL := :OLD.SALARY;
    V_NEW_SAL := :NEW.SALARY;

    SELECT J.MAX_SALARY
    INTO   J_MAX
    FROM   JOBS J
    WHERE  J.JOB_ID = :NEW.JOB_ID;

    -- Block pay cuts
    IF V_NEW_SAL < V_OLD_SAL THEN
        V_NEW_SAL := V_OLD_SAL;
    END IF;

    -- Apply the job ceiling
    IF V_NEW_SAL > J_MAX THEN
        V_NEW_SAL := J_MAX;
    END IF;

    -- Store the corrected salary
    :NEW.SALARY := V_NEW_SAL;
END;
/

CREATE OR REPLACE TRIGGER SAL_LOG_TRIG
AFTER UPDATE OF SALARY
ON EMPLOYEES
FOR EACH ROW
DECLARE
    PCT_CHANGE NUMBER;
BEGIN
    -- :NEW.SALARY contains the value corrected by the BEFORE trigger
    IF :NEW.SALARY <> :OLD.SALARY THEN

        PCT_CHANGE :=
            ROUND(
                ((:NEW.SALARY - :OLD.SALARY) / :OLD.SALARY) * 100,
                2
            );

        INSERT INTO SALARY_CHANGE_LOG (
            EMPLOYEE_ID,
            OLD_SALARY,
            NEW_SALARY,
            PCT_CHANGE
        )
        VALUES (
            :NEW.EMPLOYEE_ID,
            :OLD.SALARY,
            :NEW.SALARY,
            PCT_CHANGE
        );
    END IF;
END;
/



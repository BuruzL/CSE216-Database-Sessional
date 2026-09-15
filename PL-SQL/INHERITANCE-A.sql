--test
--1. Write a PL/SQL trigger that will enforce the following business rule:
-- No employee’s salary should ever exceed the maximum salary and fall below the
-- minimum salary defined for their job in the JOBS table.
CREATE OR REPLACE TRIGGER TRIGGER_TEST1 
BEFORE INSERT OR UPDATE OF SALARY, JOB_ID ON EMPLOYEES 
FOR EACH ROW 
DECLARE 
V_MIN NUMBER;
V_MAX NUMBER;
INVALID_SAL EXCEPTION;
BEGIN 
    SELECT MIN_SALARY, MAX_SALARY
    INTO V_MIN, V_MAX 
    FROM JOBS 
    WHERE JOB_ID=:NEW.JOB_ID;

    IF :NEW.SALARY<V_MIN OR 
    :NEW.SALARY>V_MAX THEN RAISE INVALID_SAL;
    END IF;
EXCEPTION 
WHEN INVALID_SAL THEN 
DBMS_OUTPUT.PUT_LINE('CBECK');
END;
/


--2. Write a PL/SQL procedure that does the following:
-- ● Takes two input values: employee ID and new department ID
-- ● If the employee exists and the department is valid:
-- ○ Save the current job details into the JOB_HISTORY table before the
-- change
-- ○ Move the employee to the new department
-- ○ Increase their salary by 15%
-- ● Set an OUT parameter with a valid message (a short explanation like “Employee
-- transferred successfully with 15% salary increase,” or “Employee does not exist.”,
-- etc.)

  
CREATE OR REPLACE PROCEDURE EMP_EDIT
(EID IN VARCHAR2, DID IN VARCHAR2, MSG OUT VARCHAR2)
IS V_EMPLOYEE EMPLOYEES%ROWTYPE;
V_COUNT NUMBER;
BEGIN 
    SELECT * 
    INTO V_EMPLOYEE 
    FROM EMPLOYEES 
    WHERE EMPLOYEE_ID=EID;

    SELECT COUNT(*)
    INTO V_COUNT 
    FROM DEPARTMENTS 
    WHERE DEPARTMENT_ID=DID;

    IF V_COUNT=0 THEN 
    MSG:='DEPT NAI';
    RETURN;
    END IF;

    INSERT INTO JOB_HISTORY(
        employee_id,
        start_date,
        end_date,
        job_id,
        department_id
    )
    VALUES(
         v_employee.employee_id,
        v_employee.hire_date,
        SYSDATE,
        v_employee.job_id,
        v_employee.department_id
    );

    UPDATE EMPLOYEES 
    SET DEPARTMENT_ID=DID,
    SALARY=SALARY*1.15
    WHERE EMPLOYEE_ID=EID;

    COMMIT;
    MSG:='Employee transferred successfully with 15% salary increase.';

EXCEPTION 
WHEN NO_DATA_FOUND THEN 
MSG:='EMPLOYEE NAI';
WHEN OTHERS THEN 
ROLLBACK;
MSG:='ERROR'||SQLERRM;
END EMP_EDIT;
/


   

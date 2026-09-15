-- 1. Write a PL/SQL trigger that will enforce the following business rule:
-- If an employee has a manager, that manager must be in the same department as the
-- employee.


CREATE OR REPLACE TRIGGER MANAGER_TRIG 
AFTER INSERT OR UPDATE 
OF MANAGER_ID, DEPARTMENT_ID 
ON EMPLOYEES 
DECLARE V_COUNT NUMBER;
INVAL EXCEPTION;
BEGIN 
    SELECT COUNT(*)
    INTO V_COUNT 
    FROM EMPLOYEES E 
    JOIN EMPLOYEES M 
    ON E.MANAGER_ID=M.EMPLOYEE_ID 
    WHERE E.DEPARTMENT_ID<>M.DEPARTMENT_ID 
    OR E.DEPARTMENT_ID IS NULL 
    OR M.DEPARTMENT_ID IS NULL;

    IF V_COUNT>0 THEN
    RAISE INVAL;
    -- RAISE_APPLICATION_ERROR(
    --     -20001, 
    --     'EMP AND MAN MUST BE IN SAME DEPT'
    -- );
    END IF;
EXCEPTION 
WHEN INVAL THEN 
DBMS_OUTPUT.PUT_LINE('JHAMELA ASE');
END;
/


-- 2. Create the following table in the HR schema:
-- CREATE TABLE SALARY_AUDIT_LOG (
-- audit_id NUMBER GENERATED ALWAYS AS IDENTITY
-- CONSTRAINT salary_audit_pk PRIMARY KEY,
-- employee_id NUMBER
-- CONSTRAINT salary_audit_emp_nn NOT NULL,
-- old_salary NUMBER(8,2)
-- CONSTRAINT salary_audit_old_nn NOT NULL,
-- new_salary NUMBER(8,2)
-- CONSTRAINT salary_audit_new_nn NOT NULL,
-- changed_by VARCHAR2(30)
-- CONSTRAINT salary_audit_user_nn NOT NULL,
-- change_date DATE
-- CONSTRAINT salary_audit_date_nn NOT NULL,
-- reason VARCHAR2(200),
-- CONSTRAINT salary_audit_emp_fk
-- FOREIGN KEY (employee_id)
-- REFERENCES employees(employee_id)
-- );
-- Now, write a PL/SQL function that updates an employee’s salary according to the
-- following requirements:
-- ● Take four input parameters: employee ID, percentage change, user, and reason.
-- ● The company policy for salary change percentage is:
-- ○ Maximum salary increase: 30%
-- ○ Maximum salary decrease: 20%
-- ● Make proper validation of all inputs
-- ● Calculate the new salary and update it in the appropriate table.
-- ● Insert a record into SALARY_AUDIT_LOG
-- ● Returns appropriate status message, like ‘Invalid percentage range,’ or ‘Invalid
-- employee ID,’ or ‘Salary updated successfully and audit recorded,’ etc.


CREATE TABLE SALARY_AUDIT_LOG (
audit_id NUMBER GENERATED ALWAYS AS IDENTITY
CONSTRAINT salary_audit_pk PRIMARY KEY,
employee_id NUMBER
CONSTRAINT salary_audit_emp_nn NOT NULL,
old_salary NUMBER(8,2)
CONSTRAINT salary_audit_old_nn NOT NULL,
new_salary NUMBER(8,2)
CONSTRAINT salary_audit_new_nn NOT NULL,
changed_by VARCHAR2(30)
CONSTRAINT salary_audit_user_nn NOT NULL,
change_date DATE
CONSTRAINT salary_audit_date_nn NOT NULL,
reason VARCHAR2(200),
CONSTRAINT salary_audit_emp_fk
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id)
);

CREATE OR REPLACE FUNCTION EMP_SAL(
    EID IN NUMBER,
    PCT IN NUMBER, 
    USR IN VARCHAR2,
    REASON IN VARCHAR2
)
RETURN VARCHAR2 IS 
NEW_SAL NUMBER;
V_SAL NUMBER;

BEGIN 
    IF EID IS NULL THEN 
    RETURN 'INVALID EMP';
    END IF;

     IF PCT IS NULL OR 
    PCT<-0.20 
    OR PCT>0.30 
    THEN 
        RETURN 'INVALID PCT';
    END IF;

    IF USR IS NULL OR TRIM(USR) IS NULL THEN 
    RETURN 'INVALID USER';
    END IF;

    IF REASON IS NULL OR TRIM(REASON) IS NULL THEN 
    RETURN 'INVALID REASON';
    END IF;

    SAVEPOINT BEFORE_SAL_UPDATE;

    

    SELECT SALARY
     INTO V_SAL
    FROM EMPLOYEES 
    WHERE EMPLOYEE_ID=EID
    FOR UPDATE;
   

    NEW_SAL:=V_SAL+V_SAL*PCT;

    UPDATE EMPLOYEES 
    SET SALARY=NEW_SAL
    WHERE EMPLOYEE_ID=EID;

    INSERT INTO SALARY_AUDIT_LOG(
        EMPLOYEE_ID, 
        OLD_SALARY,
        NEW_SALARY,
          CHANGED_BY, 
          CHANGE_DATE,
        REASON
    )VALUES(
        EID, 
        V_SAL,
        NEW_SAL,
        USR,
        SYSDATE,
        REASON
    );

    RETURN 'SALARY SUCC';
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    RETURN 'INVALID EMP';
    WHEN OTHERS THEN 
    ROLLBACK TO BEFORE_SAL_UPDATE;
    RETURN 'KI JANI HOISE';
END EMP_SAL;
/



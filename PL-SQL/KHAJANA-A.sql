-- 1. The organization wants to generate a summary of employees who act as managers. An
-- employee is considered a manager if at least one employee has that person's
-- EMPLOYEE_ID stored as their MANAGER_ID.
-- A table named MANAGER_SUMMARY needs to be created:
-- CREATE TABLE MANAGER_SUMMARY (
-- MANAGER_ID NUMBER,
-- DEPARTMENT_ID NUMBER,
-- MANAGER_NAME VARCHAR2(100),
-- DIRECT_REPORT_COUNT NUMBER,
-- GENERATED_BY VARCHAR2(30),
-- GENERATED_ON DATE
-- );
-- Tasks:
-- (a) Function
-- Write a function
-- GET_DIRECT_REPORT_COUNT (
-- P_EMP_ID IN NUMBER
-- ) RETURN NUMBER
-- that returns the number of employees who directly report to the employee identified by
-- P_EMP_ID.
-- For example, direct reports of employee 103 are those employees whose:
-- MANAGER_ID = 103
-- The function should return 0 if the employee has no direct reports.

-- (b) Procedure
-- Write a procedure
-- BUILD_MANAGER_SUMMARY (
-- P_DEPT_ID IN NUMBER,
-- P_MANAGER_COUNT OUT NUMBER,
-- P_TOTAL_REPORTS OUT NUMBER
-- )
-- that performs the following:
-- ● Deletes previous rows from MANAGER_SUMMARY for the given department.
-- ● Processes every employee belonging to P_DEPT_ID.
-- ● For each employee, calls GET_DIRECT_REPORT_COUNT.
-- ● If the returned number is greater than zero, the employee is considered a
-- manager. Insert the following into MANAGER_SUMMARY:
-- ○ employee ID
-- ○ department ID
-- ○ employee's full name
-- ○ number of direct reports
-- ○ database user
-- ○ current date/time
-- ● Return:
-- ○ P_MANAGER_COUNT = number of managers found in the department
-- ○ P_TOTAL_REPORTS = sum of the direct-report counts of those managers
-- ○

-- If the department contains no employees, print:
-- No employees in department <id>
-- and return 0 for both OUT parameters.
-- When counting direct reports, count all direct reports of the manager, regardless of which
-- department those employees belong to.
-- (c) Anonymous block
-- Write an anonymous PL/SQL block that executes the procedure for:
-- Department ID = 50 and prints the two OUT parameter values.


CREATE TABLE MANAGER_SUMMARY (
MANAGER_ID NUMBER,
DEPARTMENT_ID NUMBER,
MANAGER_NAME VARCHAR2(100),
DIRECT_REPORT_COUNT NUMBER,
GENERATED_BY VARCHAR2(30),
GENERATED_ON DATE
);

CREATE OR REPLACE FUNCTION GET_DIRECT_REPORT_COUNT(
    P_EMP_ID IN NUMBER 
)RETURN NUMBER IS 
--VARS
V_COUNT NUMBER;
BEGIN 

    BEGIN
     SELECT COUNT(*)
    INTO V_COUNT 
    FROM EMPLOYEES E 
    WHERE MANAGER_ID=P_EMP_ID;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    RETURN 0;
    END;

    RETURN V_COUNT;
    END GET_DIRECT_REPORT_COUNT;
/


CREATE OR REPLACE procedure BUILD_MANAGER_SUMMARY(
    P_DEPT_ID IN NUMBER,
P_MANAGER_COUNT OUT NUMBER,
P_TOTAL_REPORTS OUT NUMBER
) IS 
--VAR 
V_REPORT_COUNT NUMBER;
V_EMPLOYEE_COUNT NUMBER := 0;
BEGIN 
    DELETE FROM MANAGER_SUMMARY
    WHERE DEPARTMENT_ID=P_DEPT_ID;

P_MANAGER_COUNT:=0;
P_TOTAL_REPORTS:=0;

FOR EMP_REC IN (
    SELECT EMPLOYEE_ID,
    DEPARTMENT_ID,
     FIRST_NAME,
               LAST_NAME
    FROM EMPLOYEES 
    WHERE DEPARTMENT_ID=P_DEPT_ID
)LOOP 
    V_EMPLOYEE_COUNT:=V_EMPLOYEE_COUNT+1;
    V_REPORT_COUNT:=GET_DIRECT_REPORT_COUNT(EMP_REC.EMPLOYEE_ID);
    IF(V_REPORT_COUNT>0) THEN 
    INSERT INTO MANAGER_SUMMARY(
         MANAGER_ID,
                DEPARTMENT_ID,
                MANAGER_NAME,
                DIRECT_REPORT_COUNT,
                GENERATED_BY,
                GENERATED_ON
    )VALUES(
         EMP_REC.EMPLOYEE_ID,
                EMP_REC.DEPARTMENT_ID,
                EMP_REC.FIRST_NAME || ' ' || EMP_REC.LAST_NAME,
                V_REPORT_COUNT,
                USER,
                SYSDATE
    );

    P_MANAGER_COUNT:=P_MANAGER_COUNT+1;
     P_TOTAL_REPORTS := P_TOTAL_REPORTS + V_REPORT_COUNT;
     END IF;
     END LOOP;
 IF V_EMPLOYEE_COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'No employees in department ' || P_DEPT_ID
        );

        P_MANAGER_COUNT := 0;
        P_TOTAL_REPORTS := 0;
    END IF;
END BUILD_MANAGER_SUMMARY;
/

SET SERVEROUTPUT ON;
DECLARE 
 V_MANAGER_COUNT NUMBER;
    V_TOTAL_REPORTS NUMBER;
BEGIN 
    BUILD_MANAGER_SUMMARY(
        50, V_MANAGER_COUNT, V_TOTAL_REPORTS
    );
     DBMS_OUTPUT.PUT_LINE(
        'Manager count: ' || V_MANAGER_COUNT
    );

    DBMS_OUTPUT.PUT_LINE(
        'Total direct reports: ' || V_TOTAL_REPORTS
    );
END;
/

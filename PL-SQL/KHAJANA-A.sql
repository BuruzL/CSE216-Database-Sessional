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


-- 2. When a department moves to a different office (its LOCATION_ID in DEPARTMENTS
-- changes), every employee currently in that department receives a permanent relocation
-- adjustment to their salary. The size of the raise depends on how far the department moves:

-- Move (checked top to bottom) RELOCATION_TYPE Raise
-- new location is in the same country DOMESTIC 3 %
-- different country, but same region REGIONAL 8 %
-- different region OVERSEAS 12 %

-- The country of a location is LOCATIONS.COUNTRY_ID; the region of a country is
-- COUNTRIES.REGION_ID.
-- Create the following table:
-- CREATE TABLE DEPT_RELOCATION_LOG (
-- DEPARTMENT_ID NUMBER,
-- OLD_LOCATION_ID NUMBER,
-- NEW_LOCATION_ID NUMBER,
-- OLD_CITY VARCHAR2(30),
-- NEW_CITY VARCHAR2(30),
-- RELOCATION_TYPE VARCHAR2(15),
-- RAISE_PCT NUMBER,
-- EMPLOYEES_AFFECTED NUMBER,
-- CHANGED_BY VARCHAR2(30),
-- CHANGED_ON DATE
-- );
-- Task:
-- Create a row-level trigger on DEPARTMENTS that fires whenever LOCATION_ID is updated. If
-- the location actually changes:
-- ● Look up the city, country and region of both the old and the new location.
-- ● Decide the relocation type and raise percentage from the table above.
-- ● Count the employees currently in that department.
-- ● Increase the salary of every employee of that department:
-- ROUND(SALARY * (100 + pct) / 100, 2)
-- ● Insert one row into DEPT_RELOCATION_LOG containing:
-- ○ department ID
-- ○ old and new location IDs
-- ○ old and new cities
-- ○ relocation type
-- ○ raise percentage
-- ○ number of employees affected

-- ○ database user
-- ○ current date/time
-- ● A department with no employees is still relocated and logged, with 0 employees
-- affected.
-- ● If an UPDATE assigns the location the department already has, give no raise and
-- write no log row.
-- For this question, you may assume that all location IDs used in the test cases are valid
-- and non-NULL.
-- Demonstrate your trigger using suitable UPDATE statements (include at least one
-- UPDATE that relocates more than one department at once) and show:
-- SELECT *
-- FROM DEPT_RELOCATION_LOG;
-- Also display the affected employee rows afterward to verify that their SALARY values
-- were changed correctly.
-- Test driver:
-- Test 1: DOMESTIC move (Southlake US → South San Francisco US)
-- UPDATE DEPARTMENTS
-- SET LOCATION_ID = 1500
-- WHERE DEPARTMENT_ID = 60;
-- All 5 IT employees get 3 %.
-- Test 2: REGIONAL move (Munich DE → London GB, both Europe)
-- UPDATE DEPARTMENTS
-- SET LOCATION_ID = 2400
-- WHERE DEPARTMENT_ID = 70;
-- Employee 204 gets 8 %.
-- Test 3: OVERSEAS move (Toronto CA, Americas → Tokyo JP, Asia)
-- UPDATE DEPARTMENTS
-- SET LOCATION_ID = 1200
-- WHERE DEPARTMENT_ID = 20;
-- Employees 201 and 202 get 12 %.
-- Test 4: Assign the same location
-- UPDATE DEPARTMENTS
-- SET LOCATION_ID = 2400
-- WHERE DEPARTMENT_ID = 40;
-- Department 40 is already in London, so no raise and no log row.

-- Test 5: Two empty departments in ONE statement (Seattle US → Toronto CA)
-- UPDATE DEPARTMENTS
-- SET LOCATION_ID = 1800
-- WHERE DEPARTMENT_ID IN (130, 140);
-- The trigger fires once per row, so this single UPDATE writes two log rows, each with 0
-- employees affected.
-- Verify the log
-- SELECT DEPARTMENT_ID, OLD_LOCATION_ID,
-- NEW_LOCATION_ID, OLD_CITY, NEW_CITY,
-- RELOCATION_TYPE, RAISE_PCT,
-- EMPLOYEES_AFFECTED
-- FROM DEPT_RELOCATION_LOG
-- ORDER BY DEPARTMENT_ID;
-- The rows should be equivalent to (exactly five rows):
-- DEP
-- T
-- OLD_L
-- OC
-- NEW_LOC TYPE PCT AFFECTED

-- 20 1800 1200 OVERSEAS 12 2
-- 60 1400 1500 DOMESTIC 3 5
-- 70 2700 2400 REGIONAL 8 1
-- 130 1700 1800 REGIONAL 8 0
-- 140 1700 1800 REGIONAL 8 0

-- with the city columns:
-- DEPT OLD_CITY NEW_CITY
-- 20 Toronto Tokyo
-- 60 Southlake South San
-- Francisco
-- 70 Munich London
-- 130 Seattle Toronto
-- 140 Seattle Toronto

-- There should be no log row for department 40, because the value of LOCATION_ID did not
-- actually change.

-- Verify the employees
-- SELECT EMPLOYEE_ID, DEPARTMENT_ID, SALARY
-- FROM EMPLOYEES
-- WHERE DEPARTMENT_ID IN (20, 40, 60, 70)
-- ORDER BY DEPARTMENT_ID, EMPLOYEE_ID;
-- EMPLOYEE_I
-- D

-- DEPT_ID OLD
-- SALARY

-- NEW
-- SALARY
-- 201 20 13000 14560
-- 202 20 6000 6720
-- 203 40 6500 6500
-- 103 60 9000 9270
-- 104 60 6000 6180
-- 105 60 4800 4944
-- 106 60 4800 4944
-- 107 60 4200 4326
-- 204 70 10000 10800

-- Finally:
-- ROLLBACK;


CREATE TABLE DEPT_RELOCATION_LOG (
DEPARTMENT_ID NUMBER,
OLD_LOCATION_ID NUMBER,
NEW_LOCATION_ID NUMBER,
OLD_CITY VARCHAR2(30),
NEW_CITY VARCHAR2(30),
RELOCATION_TYPE VARCHAR2(15),
RAISE_PCT NUMBER,
EMPLOYEES_AFFECTED NUMBER,
CHANGED_BY VARCHAR2(30),
CHANGED_ON DATE
);


CREATE OR REPLACE TRIGGER DEPT_TRIG 
AFTER UPDATE 
OF LOCATION_ID 
ON DEPARTMENTS 
FOR EACH ROW
DECLARE 
V_OLD_CITY LOCATIONS.CITY%TYPE;
V_NEW_CITY LOCATIONS.CITY%TYPE;
V_OLD_COUNTRY LOCATIONS.COUNTRY%TYPE;
V_NEW_COUNTRY    LOCATIONS.COUNTRY_ID%TYPE;
    V_OLD_REGION     COUNTRIES.REGION_ID%TYPE;
    V_NEW_REGION     COUNTRIES.REGION_ID%TYPE;

V_RELOCATION_TYPE DEPT_RELOCATION_LOG.RELOCATION_TYPE%TYPE;
V_RAISE_PCT DEPT_RELOCATION_LOG.RAISE_PCT%TYPE;
V_EMP_COUNT        NUMBER;
BEGIN 
    IF :OLD.LOCATION_ID<>:NEW.LOCATION_ID THEN 
        --GETTING OLD STUFF
        SELECT L.CITY, 
        L.COUNTRY_ID,
        C.REGION_ID
        INTO V_OLD_CITY,
        V_OLD_COUNTRY,
        V_OLD_REGION 
        FROM LOCATIONS L 
        JOIN COUNTRIES C 
        ON C.COUNTRY_ID=L.COUNTRY_ID
        WHERE L.LOCATION_ID=:OLD.LOCATION_ID;

        --NEW INFO
          SELECT L.CITY, 
        L.COUNTRY_ID,
        C.REGION_ID
        INTO V_OLD_CITY,
        V_OLD_COUNTRY,
        V_OLD_REGION 
        FROM LOCATIONS L 
        JOIN COUNTRIES C 
        ON C.COUNTRY_ID=L.COUNTRY_ID
        WHERE L.LOCATION_ID=:NEW.LOCATION_ID;

        IF V_OLD_COUNTRY=V_NEW_COUNTRY THEN 
        V_RELOCATION_TYPE:='DOMESTIC';
        V_RAISE_PCT:=3;

        ELSIF V_OLD_REGION=V_NEW_REGION THEN 
          V_RELOCATION_TYPE := 'REGIONAL';
            V_RAISE_PCT       := 8;

         ELSE
            V_RELOCATION_TYPE := 'OVERSEAS';
            V_RAISE_PCT       := 12;
        END IF;

        BEGIN 
            SELECT COUNT(*)
            INTO V_EMP_CNT 
            FROM EMPLOYEES 
            WHERE DEPARTMENT_ID=:NEW.DEPARTMENT_ID;
            END;
        
        UPDATE EMPLOYEES 
        SET SALARY=SALARY*(100+V_RAISE_PCT)/100
        WHERE DEPARTMENT_ID=:NEW.DEPARTMENT_ID;

        INSERT INTO DEPT_RELOCATION_LOG (
            DEPARTMENT_ID,
            OLD_LOCATION_ID,
            NEW_LOCATION_ID,
            OLD_CITY,
            NEW_CITY,
            RELOCATION_TYPE,
            RAISE_PCT,
            EMPLOYEES_AFFECTED,
            CHANGED_BY,
            CHANGED_ON
        ) VALUES (
            :NEW.DEPARTMENT_ID,
            :OLD.LOCATION_ID,
            :NEW.LOCATION_ID,
            V_OLD_CITY,
            V_NEW_CITY,
            V_RELOCATION_TYPE,
            V_RAISE_PCT,
            V_EMP_COUNT,
            USER,
            SYSDATE
        );

    END IF;
END;
/



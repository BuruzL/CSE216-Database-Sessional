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

-- 2. Write a PL/SQL function that checks whether an employee is currently paid more than
-- they should be according to their job and years of service.
-- The function should:
-- ● Take one input parameter: employee ID
-- ● Check if the employee exists in the EMPLOYEES table. If not → return NULL
-- ● Calculate years of service = number of full years since hire date until today (use
-- FLOOR)
-- ● Apply this simple overpay rule:
-- ○ If years of service ≥ 10 → employee should not earn more than 95% of
-- maximum salary
-- ○ If years of service ≥ 5 and < 10 → employee should not earn more than
-- 90% of the maximum salary
-- ○ If years of service < 5 → employee should not earn more than 85% of the
-- maximum salary

-- ● Return:
-- ○ 1 → if the employee is overpaid (salary > the allowed percentage of
-- maximum salary)
-- ○ 0 → if the employee is within the allowed range
-- ○ -1 → if the employee has no job or the job data is missing


CREATE OR REPLACE FUNCTION EMP_FUN(EID IN NUMBER)
RETURN NUMBER IS 
--VARIABLES 
YEARS NUMBER;
H_DATE DATE;
M_SAL NUMBER;
V_SAL NUMBER;
CHK NUMBER;
--
V_JOB_ID VARCHAR2(10);
BEGIN 
    IF EID IS NULL THEN 
    RETURN NULL;
    END IF;

  
BEGIN
    SELECT HIRE_DATE , SALARY, JOB_ID 
    INTO H_DATE , V_SAL, V_JOB_ID 
    FROM EMPLOYEES 
    WHERE EID=EMPLOYEE_ID;
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
RETURN NULL;
END;


   IF V_JOB_ID IS NULL THEN
        RETURN -1;
    END IF;

    BEGIN 
    SELECT MAX(SALARY)
    INTO M_SAL
    FROM EMPLOYEES 
    WHERE JOB_ID=V_JOB_ID;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;
    END;


    IF M_SAL IS NULL THEN
        RETURN -1;
    END IF;

    YEARS:=(MONTHS_BETWEEN(SYSDATE, H_DATE))/12;
    CHK:=0;

    IF YEARS>=10 AND V_SAL>(0.95*M_SAL) THEN 
    CHK:=1;
    ELSIF YEARS>=5 AND YEARS<10 AND V_SAL>(0.9*M_SAL)then
    CHK:=1;
    ELSIF YEARS<5 AND V_SAL>(0.85*M_SAL) THEN 
    CHK:=1;
    END IF;
RETURN CHK;
END EMP_FUN;
/





CREATE TABLE A2P2_Departments (
    DepartmentID    NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    DepartmentName  NVARCHAR2(50) NOT NULL,
    DepartmentDesc  NVARCHAR2(100) DEFAULT 'Dept. Description to be determined' NOT NULL 
);

CREATE TABLE A2P2_Employees (
    EmployeeID          NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    DepartmentID        NUMBER(10),
    ManagerEmployeeID   NUMBER(10),
    FirstName           NVARCHAR2(50),
    LastName            NVARCHAR2(50),
    Salary              NUMBER(18,2),
    CommissionBonus     NUMBER(18,2),
    FileFolder          NVARCHAR2(256) DEFAULT 'ToBeBuilt',
    CONSTRAINT PK_Ass2Employees_ID PRIMARY KEY (EmployeeID),
    CONSTRAINT FK_Ass2Employee_Department FOREIGN KEY (DepartmentID) REFERENCES A2P2_Departments ( DepartmentID ),
    CONSTRAINT FK_Ass2Employee_Manager FOREIGN KEY (ManagerEmployeeID) REFERENCES A2P2_Employees ( EmployeeID ),
    CONSTRAINT CK_Ass2EmployeeSalary CHECK ( Salary >= 0 ),
    CONSTRAINT CK_Ass2EmployeeCommission CHECK ( CommissionBonus >= 0 )
);



INSERT INTO A2P2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Management', 'Executive Management' );
INSERT INTO A2P2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'HR', 'Human Resources' );
INSERT INTO A2P2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'DatabaseMgmt', 'Database Management');
INSERT INTO A2P2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Support', 'Product Support' );
INSERT INTO A2P2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Software', 'Software Sales' );
INSERT INTO A2P2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Peripheral', 'Peripheral Sales' );


INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 1, NULL, 'Sarah', 'Campbell', 76000, NULL, 'SarahCampbell' );
INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, 1, 'James', 'Donoghue',     66000 , NULL, 'JamesDonoghue');
INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 1, 1, 'Hank', 'Brady',        74000 , NULL, 'HankBrady');
INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 2, 1, 'Samantha', 'Jones',    71000, NULL , 'SamanthaJones');
INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, 4, 'Fred', 'Judd',         42000, 4000, 'FredJudd');
INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, NULL, 'Hannah', 'Grant',   65000, 3000 ,  'HannahGrant');
INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, 4, 'Dhruv', 'Patel',       64000, 2000 ,  'DhruvPatel');
INSERT INTO A2P2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 4, 3, 'Ash', 'Mansfield',     52000, 5000 ,  'AshMansfield');


CREATE OR REPLACE FUNCTION A2P2_GetEmployeeID (FName IN NVARCHAR2, LName IN NVARCHAR2 )
RETURN NUMBER
IS
   EmpID NUMBER(10);
BEGIN
    SELECT EmployeeID INTO EmpID 
    FROM A2P2_Employees
    WHERE FirstName = FName AND LastName = LName;

    RETURN EmpID;
    
    -- Add exception section to make sure the function return null when no data found
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
END;
/

/* REQUIREMENT 1*/ --COMPLETED
CREATE OR REPLACE PROCEDURE A2P2_InsertDept (dept_name A2P2_Departments.DepartmentName%TYPE, 
                                            dept_desc A2P2_Departments.DepartmentDesc%TYPE DEFAULT 'Dept. Description to be determined')
AS
BEGIN
    INSERT INTO A2P2_Departments (DepartmentName, DepartmentDesc)
    VALUES (dept_name, dept_desc);
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred: '||SQLERRM);
END A2P2_InsertDept;
/
--TESTING
BEGIN
    A2P2_InsertDept ('SQA', 'Software Quality Assurance');
    A2P2_InsertDept ('Engineering', 'Systems Design and Development');
    A2P2_InsertDept ('TechSupport');
END;
/
/* REQUIREMENT 2*/ --COMPLETED
CREATE OR REPLACE FUNCTION A2P2_GetDepartmentID (dept_name A2P2_Departments.DepartmentName%TYPE)
RETURN NUMBER
AS
    v_dept_id NUMBER;
BEGIN
    SELECT DepartmentID
    INTO v_dept_id
    FROM A2P2_Departments
    WHERE DepartmentName = dept_name;
    
    RETURN v_dept_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
END A2P2_GetDepartmentID;
/

/* REQUIREMENT 3*/ --COMPLETED
CREATE OR REPLACE PROCEDURE A2P2_InsertEmployees (
        dept_name A2P2_Departments.DepartmentName%TYPE,
        emp_fname A2P2_Employees.FirstName%TYPE,
        emp_lname A2P2_Employees.LastName%TYPE,
        emp_ffolder A2P2_Employees.FileFolder%TYPE,
        mng_fname A2P2_Employees.FirstName%TYPE,
        mng_lname A2P2_Employees.LastName%TYPE,
        emp_salary A2P2_Employees.Salary%TYPE DEFAULT 45000,
        emp_com A2P2_Employees.CommissionBonus%TYPE DEFAULT 1500       
    )
AS
    v_dept_id A2P2_Departments.DepartmentID%TYPE;
    v_emp_id A2P2_Employees.EmployeeID%TYPE;
    v_mng_salary A2P2_Employees.Salary%TYPE DEFAULT 45000;
    v_mng_com A2P2_Employees.CommissionBonus%TYPE DEFAULT 1500;
BEGIN
    -- 1. Department Info
    BEGIN
        v_dept_id := A2P2_GetDepartmentID(dept_name);
        
        -- Insert new department if not exists
        IF v_dept_id IS NULL THEN
            A2P2_InsertDept(dept_name);
            v_dept_id := A2P2_GetDepartmentID(dept_name);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in Department Info: ' || SQLERRM);
    END; 

    -- 2. Manager Info
    BEGIN
        v_emp_id := A2P2_GetEmployeeID(mng_fname, mng_lname);
        
        -- Insert new manager if not exists
        IF v_emp_id IS NULL THEN        
            INSERT INTO A2P2_Employees (DepartmentID, FirstName, LastName, Salary, CommissionBonus)
            VALUES (v_dept_id, mng_fname, mng_lname, v_mng_salary, v_mng_com);
            v_emp_id := A2P2_GetEmployeeID(mng_fname, mng_lname);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in Manager Info: ' || SQLERRM);
    END;
    
    -- 3. Insert new employee
    BEGIN
        INSERT INTO A2P2_Employees (DepartmentID, ManagerEmployeeID, FirstName, LastName, FileFolder, Salary, CommissionBonus)
        VALUES (v_dept_id, v_emp_id, emp_fname, emp_lname, emp_ffolder, emp_salary, emp_com);

        COMMIT; -- Everything is committed only if all steps succeed
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in Employee Insertion: ' || SQLERRM);
            ROLLBACK; -- Undo department and manager inserts if employee insert fails
    END;
END A2P2_InsertEmployees;
/
-- TESTING
BEGIN
    A2P2_InsertEmployees (
        'DatabaseMgmt'
        ,'Vetri'
        ,'Velan'
        ,'VetriVelan'
        ,'Osam'
        ,'Ali'
        ,123456789
        ,2345678
        );
END;
/
/* REQUIREMENT 4*/ --COMPLETED

-- Define object type that contains all required information columns
CREATE OR REPLACE TYPE rec_emp_dept AS OBJECT (
    v_emp_fname NVARCHAR2(50),
    v_emp_lname NVARCHAR2(50),
    v_emp_salary NUMBER(18, 2),
    v_emp_com NUMBER(18, 2),
    v_emp_ffolder NVARCHAR2(256),
    v_dept_name NVARCHAR2(50),
    v_dept_desc NVARCHAR2(100)
);
/
-- Define table type of above
CREATE OR REPLACE TYPE tbl_emp_dept AS TABLE OF rec_emp_dept;
/
-- Define function
CREATE OR REPLACE FUNCTION A2P2_GetEmployeesBySal (emp_sal A2P2_Employees.Salary%TYPE)
RETURN tbl_emp_dept
AS
    v_info tbl_emp_dept := tbl_emp_dept();
BEGIN
    -- Only do if the salary is  >= 0
    IF emp_sal >= 0 THEN
        FOR rec IN (
            SELECT 
                    e.FirstName,
                    e.LastName,
                    e.Salary,
                    e.CommissionBonus,
                    e.FileFolder,
                    d.DepartmentName,
                    d.DepartmentDesc
            FROM A2P2_Employees e
            LEFT JOIN A2P2_Departments d
                ON e.DepartmentID = d.DepartmentID
            WHERE e.Salary > emp_sal
            )
            LOOP
                v_info.EXTEND;
                v_info(v_info.LAST) := rec_emp_dept (rec.FirstName
                                                    , rec.LastName
                                                    , rec.Salary
                                                    , rec.CommissionBonus
                                                    , rec.FileFolder
                                                    , rec.DepartmentName
                                                    , rec.DepartmentDesc);
            END LOOP;
    ELSE 
        RETURN NULL;
    END IF;
    
    RETURN v_info;
END A2P2_GetEmployeesBySal;
/
-- TESTING
SELECT *
FROM TABLE(A2P2_GetEmployeesBySal(45000));
/
/* REQUIREMENT 5*/ --COMPLETED
SELECT 
    DepartmentID,
    FirstName,
    LastName,
    Salary,
    CommissionBonus,
    
    -- Rank employees by department, based on descending CommissionBonus
    RANK() OVER(PARTITION BY DepartmentID ORDER BY CommissionBonus DESC) AS RankEmployee,
    
    -- Get the name and Commission of the person above them 
    LAG(FirstName, 1) OVER(PARTITION BY DepartmentID ORDER BY CommissionBonus DESC) AS PriorEmployeeName,
    LAG(CommissionBonus, 1) OVER(PARTITION BY DepartmentID ORDER BY CommissionBonus DESC) AS PriorEmployeeBonus,
    
    -- Average commission that shows how each person and department compares to each other
    AVG(COALESCE(CommissionBonus,0)) OVER(PARTITION BY DepartmentID) AS AvgCommission,
    
    -- Add a TotalCompensation column that shows the total of Salary + CommissionBonus
    (Salary + CommissionBonus) AS TotalCompensation
FROM A2P2_Employees;


/* REQUIREMENT 6*/ --COMPLETED
WITH cte_mng(EmployeeID, DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder, FilePath) AS (
        -- Get Top-Managers
        SELECT EmployeeID
                , DepartmentID
                , ManagerEmployeeID 
                , FirstName
                , LastName 
                , Salary 
                , CommissionBonus
                , FileFolder
                , FileFolder
        FROM A2P2_Employees s
        WHERE ManagerEmployeeID IS NULL
        
        UNION ALL
        -- Get employee who report to appropriate manager in above list
        SELECT e.EmployeeID
                , e.DepartmentID
                , e.ManagerEmployeeID
                , e.FirstName
                , e.LastName
                , e.Salary
                , e.CommissionBonus
                , e.FileFolder
                , m.FilePath || '\' || e.FileFolder
        FROM A2P2_Employees e
        JOIN cte_mng m
            ON e.ManagerEmployeeID = m.EmployeeID
            )
SELECT EMPLOYEEID
        , DEPARTMENTID
        , MANAGEREMPLOYEEID
        , FIRSTNAME
        , LASTNAME
        , SALARY
        , COMMISSIONBONUS
        , FILEFOLDER
        , FILEPATH
FROM cte_mng;
        


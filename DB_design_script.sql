-- CREATE DB/TABLES AND POPULATE TABLE

CREATE DATABASE employeeDB;

USE employeeDB;

--EMPLOYEE TABLE
CREATE TABLE employee(EmpID NVARCHAR(3) NOT NULL, 
	EmpName NVARCHAR(30), Salary INT, DepartmentID NVARCHAR(2),
	StateID NVARCHAR(3));
	
--POPULATE EMPLOYEE TABLE
INSERT INTO employee VALUES
	('A01', 'Monika singh', 10000, '1', '101'),
	('A02', 'Vishal kumar', 25000, '2', '101'),
	('B01', 'Sunil Rana', 10000, '3', '102'),
	('B02', 'Saurav Rawat', 15000, '2', '103'),
	('B03', 'Vivek Kataria', 19000, '4', '104'),
	('C01', 'Vipul Gupta', 45000, '2', '105'),
	('C02', 'Geetika Basin', 33000, '3', '101'),
	('C03', 'Satish Sharama', 45000, '1', '103'),
	('C04', 'Sagar Kumar', 50000, '2', '102'),
	('C05', 'Amitabh singh', 37000, '3', '108');


--DEPARTMENT TABLE
CREATE TABLE Department
	(DepartmentID NVARCHAR(2), DepartmentName NVARCHAR(30));

--POPULATE DEPARTMENT TABLE
INSERT INTO Department
	VALUES ('1', 'IT'),
	('2', 'HR'),
	('3', 'Admin'),
	('4', 'Account');


--PROJECT MANAGER TABLE
CREATE TABLE Projectmanager
	(ProjectManagerID NVARCHAR(2), ProjectManagerName NVARCHAR(20),
	DepartmentID NVARCHAR(2));

--POPULATE PROJECT MANAGER TABLE
INSERT INTO Projectmanager
	VALUES ('1', 'Monika', '1'),
	('2', 'Vivek', '1'),
	('3', 'Vipul', '2'),
	('4', 'Satish', '2'),
	('5', 'Amitabh', '3');


--STATEMASTER TABLE
CREATE TABLE Statemaster (StateID NVARCHAR(3), 
	StateName NVARCHAR(20));

--POPULATE STATEMASTER TABLE
INSERT INTO Statemaster
	VALUES ('101', 'Lagos'),
	('102', 'Abuja'),
	('103', 'Kano'),
	('104', 'Delta'),
	('105', 'Ido'),
	('106', 'Ibadan');



--TEST QUESTIONS WITH THEIR ANSWERS

-- QUESTION 1: Write a SQL query to fetch the list of employees with same salary? 
SELECT *
FROM employee
WHERE Salary IN (
    SELECT Salary
    FROM employee
    GROUP BY Salary
    HAVING COUNT(Salary) > 1
);


-- QUESTION 2: Write a SQL query to fetch Find the second highest salary.
SELECT Salary
FROM employee
ORDER BY Salary DESC
	OFFSET 1 ROW
	FETCH NEXT 1 ROW ONLY;


--QUESTION 3: Please write a query to get the maximum salary from each department. 
SELECT MAX(Salary) highest_salary 
FROM employee 
GROUP BY DepartmentID;

-- QUESTION 4: Write a SQL query to fetch Projectmanger-wise count of employees sorted by projectmanger's count in descending order.
SELECT COUNT(DISTINCT E.EmpName) count_of_PMs --EmpName, DepartmentID, EmpID 
FROM employee E, Projectmanager P
WHERE E.DepartmentID = P.DepartmentID
GROUP BY P.ProjectManagerID
ORDER BY count_of_PMs DESC;

-- QUIESTION 5: Write a query to fetch only the first name from the EmpName column of Employee table and after that add the salary for example- empname is “Amit singh”  and salary is 10000 then output should be Amit_10000
SELECT CONCAT(LEFT(EmpName, 
		CHARINDEX(' ', EmpName) - 1), '_', Salary) FirstName_Salary
FROM employee;

-- QUESTION 6: Write a SQL query to fetch only odd rows from table.
SELECT Salary FROM employee
WHERE Salary % 2 = 1;

--QUESTION 7: Create a Stored procedures  to fetch EmpID,Empname, Departmantname, ProjectMangerName where salary is greater than 30000.
CREATE PROCEDURE sp_GetHighSalaryEmployees
AS
BEGIN
    SELECT 
        E.EmpID, 
        E.EmpName, 
        D.DepartmentName, 
        P.ProjectManagerName
    FROM 
        employee E 
        INNER JOIN Department D ON E.DepartmentID = D.DepartmentID 
        INNER JOIN Projectmanager P ON D.DepartmentID = P.DepartmentID 
    WHERE 
        E.Salary > 30000
END
GO;
--RUN SP
EXEC sp_GetHighSalaryEmployees;


-- QUESTION 8: Create a Scalar Function to fetch the empname from Employee who has high salary and working in Admin Department.
CREATE FUNCTION GetHighestPaidAdminEmployee()
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @EmpName VARCHAR(50);
    SELECT TOP 1 @EmpName = E.EmpName
    FROM employee E
    INNER JOIN Department D ON E.DepartmentID = D.DepartmentID
    WHERE D.DepartmentName = 'Admin' AND E.Salary = (SELECT MAX(Salary) FROM employee WHERE DepartmentID = D.DepartmentID)
    RETURN @EmpName;
END
GO;
--TEST SCALAR FXN
SELECT GetHighestPaidAdminEmployee() AS HighestPaidAdminEmployee;


--QUESTION 9: Create a procedures to update the employee’s salary by 25% where department is ‘IT’ and project manger not ‘Vivek, Satish’
CREATE PROCEDURE UpdateITSalary
AS
BEGIN
    UPDATE E
    SET E.Salary = E.Salary * 1.25
    FROM employee E
    INNER JOIN Department D ON E.DepartmentID = D.DepartmentID
    INNER JOIN Projectmanager P ON D.DepartmentID = P.DepartmentID
    WHERE D.DepartmentName = 'IT'
    AND P.ProjectManagerName NOT IN ('Vivek', 'Satish')
END
GO;
--RUN SP
EXEC UpdateITSalary;
--TEST IF IT WORKS AS EXPECTED
SELECT * FROM employee;


-- QUESTION 10: Create a Stored procedures  to fetch All the empname along with Departmentname, projectmanagername, statename and  sorted by Departmantname count in descending order and use error handling also.
CREATE PROCEDURE GetEmployeeInfo
AS
BEGIN
    BEGIN TRY
        SELECT 
            E.EmpName, 
            D.DepartmentName, 
            P.ProjectManagerName, 
            S.StateName
        FROM 
            employee E
            INNER JOIN Department D ON E.DepartmentID = D.DepartmentID
            INNER JOIN Projectmanager P ON D.DepartmentID = P.DepartmentID
            INNER JOIN Statemaster S ON E.StateID = S.StateID
        ORDER BY 
            (SELECT COUNT(*) FROM Department WHERE DepartmentName = D.DepartmentName) DESC
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO;
--RUN SP AND SEE IF IT WORKS WELL
EXEC GetEmployeeInfo;

create database employees;
use employees;
-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from JobDepartment;


-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from SalaryBonus;
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

select * from Employee;
-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

select * from Qualification;
-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from Leaves;
-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from Payroll;

-- 1. EMPLOYEE INSIGHTS
-- 1 How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS unique_employee_count
FROM Employee;

-- 2 Which departments have the highest number of employees?
SELECT j.jobdept AS department,
       COUNT(e.emp_ID) AS employee_count
FROM JobDepartment j
LEFT JOIN Employee e ON e.Job_ID = j.Job_ID
GROUP BY j.jobdept
ORDER BY employee_count DESC;

-- 3 What is the average salary per department?
SELECT j.jobdept AS department,
       AVG(p.total_amount) AS avg_payroll_amount
FROM Payroll p
JOIN Employee e ON p.emp_ID = e.emp_ID
JOIN JobDepartment j ON e.Job_ID = j.Job_ID
GROUP BY j.jobdept
ORDER BY avg_payroll_amount DESC;

-- 4 Who are the top 5 highest-paid employees?
SELECT e.firstname, e.lastname, sb.amount AS salary
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- 5 What is the total salary expenditure across the company?
SELECT SUM(sb.amount) AS total_salary_expenditure FROM SalaryBonus sb;

-- 2.JOB ROLE AND DEPARTMENT ANALYSIS
-- 1 How many different job roles exist in each department?
SELECT jobdept, COUNT(Job_ID) AS total_roles
FROM JobDepartment
GROUP BY jobdept;

-- 2 What is the average salary range per department?
SELECT jobdept, AVG(amount) AS avg_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jobdept;

-- 3 Which job roles offer the highest salary?
SELECT jd.name AS job_role, sb.amount AS salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 1;

-- 4 Which departments have the highest total salary allocation?
SELECT jd.jobdept, SUM(sb.amount) AS total_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary DESC;

-- 3.QUALIFICATION AND SKILLS ANALYSIS
-- 1 How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS employees_with_qualifications
FROM Qualification;

-- 2 Which positions require the most qualifications?
SELECT Position, COUNT(QualID) AS total_requirements
FROM Qualification
GROUP BY Position
ORDER BY total_requirements DESC;

-- 3 Which employees have the highest number of qualifications?
SELECT e.firstname, e.lastname, COUNT(q.QualID) AS total_qualifications
FROM Qualification q
JOIN Employee e ON q.Emp_ID = e.emp_ID
GROUP BY e.emp_ID
ORDER BY total_qualifications DESC
LIMIT 5;

-- 4.LEAVE AND ABSENCE PATTERNS
-- 1.Which year had the most employees taking leaves?
SELECT YEAR(date) AS year, COUNT(DISTINCT emp_ID) AS employees_on_leave
FROM Leaves
GROUP BY YEAR(date)
ORDER BY employees_on_leave DESC;

-- 2 What is the average number of leave days taken per department?
SELECT jd.jobdept, COUNT(l.leave_ID) / COUNT(DISTINCT e.emp_ID) AS avg_leaves_per_emp
FROM Leaves l
JOIN Employee e ON l.emp_ID = e.emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- 3 Which employees have taken the most leaves?
SELECT e.firstname, e.lastname, COUNT(l.leave_ID) AS total_leaves
FROM Leaves l
JOIN Employee e ON l.emp_ID = e.emp_ID
GROUP BY e.emp_ID
ORDER BY total_leaves DESC
LIMIT 5;

-- 4 What is the total number of leave days taken company-wide?
SELECT COUNT(leave_ID) AS total_leave_days FROM Leaves;

-- 5 How do leave days correlate with payroll amounts?
SELECT e.firstname, e.lastname, COUNT(l.leave_ID) AS total_leaves, AVG(p.total_amount) AS avg_payroll
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID
ORDER BY avg_payroll DESC;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- 1 What is the total monthly payroll processed?
SELECT MONTH(date) AS month, SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY MONTH(date)
ORDER BY month;

-- 2 What is the average bonus given per department?
SELECT jd.jobdept, AVG(sb.bonus) AS avg_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- 3 Which department receives the highest total bonuses?
SELECT jd.jobdept, SUM(sb.bonus) AS total_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC
LIMIT 1;

-- 4 What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) AS avg_payroll_after_leaves
FROM Payroll;







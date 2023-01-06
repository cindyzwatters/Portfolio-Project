--  Original data created by Fusheng Wang and Carlo Zaniolo
--  http://www.cs.aau.dk/TimeCenter/software.htm
--  http://www.cs.aau.dk/TimeCenter/Data/employeeTemporalDataSet.zip
-- 
--  Current schema by Giuseppe Maxia 
--  Data conversion from XML to relational by Patrick Crews
-- 
-- This work is licensed under the 
-- Creative Commons Attribution-Share Alike 3.0 Unported License. 
-- To view a copy of this license, visit 
-- http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
-- Creative Commons, 171 Second Street, Suite 300, San Francisco, 
-- California, 94105, USA.
-- 
--  DISCLAIMER
--  To the best of our knowledge, this data is fabricated, and
--  it does not correspond to real people. 
--  Any similarity to existing people is purely coincidental.


 -- use employees;

 -- Overall objective is to look at salary per team.
 -- Is the salary considered inequitable per dept? Overall?

 -- Looking at size of team per department
 -- Looking at number of managers per department
 -- Looking for salaries based on departments
 -- Looking at managers salaries in reference to departments
 -- Looking at highest paid employees per department
 -- Looking at highest paid employees per hiring year

 
 -- Looking at size of team per department
SELECT 
    d.dept_name, 
    COUNT(de.emp_no) AS no_of_employees
FROM
    departments d
        JOIN
    dept_emp de ON d.dept_no = de.dept_no
GROUP BY d.dept_name
ORDER BY no_of_employees DESC;

 -- Looking at number of managers per department
SELECT 
    d.dept_name, 
    COUNT(dm.emp_no) AS no_of_managers
FROM
    departments d
        JOIN
    dept_manager dm ON d.dept_no = dm.dept_no
GROUP BY d.dept_name
ORDER BY no_of_managers DESC;

-- Looking at average salary for company
SELECT 
    ROUND(AVG(s.salary), 2) AS Avg_Salary
FROM
    departments d
        JOIN
    dept_emp e ON d.dept_no = e.dept_no
        JOIN
    salaries s ON e.emp_no = s.emp_no;
 -- Average salary 63,771.92 for corporation

 -- Looking at average salary based on the department
SELECT 
    d.dept_name, 
    ROUND(AVG(s.salary), 2) AS Avg_Salary, 
    row_number() OVER (ORDER BY ROUND(AVG(s.salary), 2) DESC) as Salary_Rank
FROM
    departments d
        JOIN
    dept_emp e ON d.dept_no = e.dept_no
        JOIN
    salaries s ON e.emp_no = s.emp_no
GROUP BY d.dept_name
ORDER BY Avg_Salary DESC;
 -- Top dept Sales w/ 80776, followed by marketing 71901, finance 70159, research 59866, production 59539
 -- Bottom departments are development 59503, CS 58755, QM 57294, and HR 55353


 -- Looking at managers salaries in relations to departments
SELECT 
    MAX(s.salary) as highest_salary,
    e.emp_no as emp_no,
    e.first_name as first_name,
    e.last_name as last_name,
    d.dept_name as dept_name
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_manager de ON e.emp_no = de.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
GROUP BY e.emp_no, e.first_name, e.last_name, d.dept_name
ORDER BY highest_salary DESC;
 -- Only 3 managers earn below average salary for company.

 -- Looking at highest paid employees per department using CTE
 -- Using earlier average datas: Sales w/ 80776, 
 -- Followed by marketing 71901, finance 70159, research 59866, production 59539
 -- Bottom departments are development 59503, CS 58755, QM 57294 
 -- Lowest is HR 55353
WITH highest_emp_dept AS (
SELECT 
    d.dept_name,
    de.emp_no,
    MAX(s.salary) AS highest_salary
FROM
    departments d
        JOIN
    dept_emp de ON d.dept_no = de.dept_no
        JOIN
    employees e ON de.emp_no = e.emp_no
        JOIN
    salaries s ON e.emp_no = s.emp_no
GROUP BY d.dept_name, de.emp_no
HAVING highest_salary > 80766
ORDER BY d.dept_name
)
SELECT
	dept_name,
    emp_no,
    highest_salary,
    ROW_NUMBER() OVER (ORDER BY highest_salary DESC) as salary_rank
FROM
	highest_emp_dept
WHERE dept_name = 'Sales';

 -- Looking at employees who make under the average salary per dept per CTE
WITH highest_emp_dept AS (
SELECT 
    d.dept_name,
    de.emp_no,
    MAX(s.salary) AS highest_salary
FROM
    departments d
        JOIN
    dept_emp de ON d.dept_no = de.dept_no
        JOIN
    employees e ON de.emp_no = e.emp_no
        JOIN
    salaries s ON e.emp_no = s.emp_no
GROUP BY d.dept_name, de.emp_no
HAVING highest_salary < 55353
ORDER BY d.dept_name
)
SELECT
	dept_name,
    emp_no,
    highest_salary,
    ROW_NUMBER() OVER (ORDER BY highest_salary ASC) as salary_rank
FROM
	highest_emp_dept
WHERE dept_name = 'Human Resources';

 -- Looking at highest paid employee per hiring year using CTE
WITH High_Salary_Year (emp_no, salary, year) AS (
	SELECT 
		s.emp_no,
        MAX(s.salary),
        YEAR(e.hire_date)
	FROM
		salaries s
			JOIN
		employees e ON s.emp_no = e.emp_no
	GROUP BY emp_no, year(e.hire_date)
    ORDER BY MAX(s.salary) DESC
)
SELECT
	emp_no,
    salary
FROM
	High_Salary_Year
WHERE
	year = 1990
HAVING salary <= 63771;
    
 -- Looking at length with company
WITH salary_length AS (
SELECT
	s.emp_no,
    MIN(s.salary) AS Starting_Wage,
    MAX(s.salary) AS Current_Wage,
    YEAR(s.to_date) AS current_wage_year,
    YEAR(e.hire_date) AS Hiring_Year,
    d.dept_name
FROM
	salaries s
		JOIN
	employees e ON s.emp_no = e.emp_no
		JOIN
	dept_emp de ON e.emp_no = de.emp_no
		JOIN
	departments d ON de.dept_no = d.dept_no
GROUP BY s.emp_no
ORDER BY current_wage DESC
)
SELECT
	dept_name,
	emp_no,
    starting_wage,
    current_wage,
    hiring_year,
    current_wage_year
FROM
	salary_length
WHERE current_wage > 63771;
 -- Multiple people had no pay increases since hiring year.
 -- Some with little to no pay increases but worked for company for nearly 1 decade.
 
 -- Creating view for visualization
CREATE VIEW v_salary_length AS
    SELECT 
        s.emp_no,
        MIN(s.salary) AS Starting_Wage,
        MAX(s.salary) AS Current_Wage,
        YEAR(s.to_date) AS current_wage_year,
        YEAR(e.hire_date) AS Hiring_Year,
        d.dept_name
    FROM
        salaries s
            JOIN
        employees e ON s.emp_no = e.emp_no
            JOIN
        dept_emp de ON e.emp_no = de.emp_no
            JOIN
        departments d ON de.dept_no = d.dept_no
    GROUP BY s.emp_no
    ORDER BY current_wage DESC;

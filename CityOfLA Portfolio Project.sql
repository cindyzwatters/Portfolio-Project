-- USE CityOfLA;

-- SELECT * FROM Benefits;

-- SELECT * FROM Payroll;

-- Salaries

 -- Looking at avg projected salaries per dept title and job class overall
SELECT 
	Dept_Title,
	Job_Class_Title,
	ROUND(AVG(Projected_Annual_Salary),2) as Avg_Proj_Annual_Salary,
	ROUND(AVG(Overtime_Pay),2) as Avg_Overtime_Pay
FROM
	Payroll
GROUP BY Dept_Title, Job_Class_Title
ORDER BY Dept_Title;

-- Looking at average benefit costs per dept title and job class overall.
SELECT
	Dept_Title,
	Job_Class_Title,
	Employment_Type,
	ROUND(AVG(Average_Benefit_Cost),2) as Avg_Benefit_Cost
FROM
	Benefits
GROUP BY Dept_Title, Job_Class_Title, Employment_Type
ORDER BY Dept_Title;
-- So far evident that part time and per events employees are not eligible for benefits

-- Looking at average payroll for part time and per events employees only.
SELECT
	b.Dept_Title,
	b.Job_Class_Title,
	b.Employment_Type,
	ROUND(AVG(b.Average_Benefit_Cost),2) as Avg_Benefit_Cost,
	ROUND(AVG(p.Projected_Annual_Salary),2) as Avg_Proj_Annual_Salary,
	ROUND(AVG(p.Overtime_Pay),2) as Avg_Overtime_Pay
FROM
	Benefits b
		JOIN
	Payroll p ON b.Dept_Title = p.Dept_Title AND b.Job_Class_Title =p.Job_Class_Title
WHERE b.Employment_Type IN ('Part Time','Per Event')
GROUP BY b.Dept_Title, b.Job_Class_Title, b.Employment_Type
ORDER BY b.Dept_Title;

-- Looking at average salary for employment types overall.
SELECT
	b.Employment_Type,
	ROUND(AVG(b.Average_Benefit_Cost),2) as Avg_Benefit_Cost,
	ROUND(AVG(p.Projected_Annual_Salary),2) as Avg_Proj_Annual_Salary,
	ROUND(AVG(p.Overtime_Pay),2) as Avg_Total_Overtime_Pay
FROM
	Benefits b
		JOIN
	Payroll p ON b.Dept_Title = p.Dept_Title AND b.Job_Class_Title = p.Job_Class_Title
GROUP BY b.Employment_Type
ORDER BY b.Employment_Type;
-- Large wage disparity between full time employees in comparison to part time and per event employees.

-- Looking at average wages across years for each department
SELECT
	Year,
	Dept_Title,
	ROUND(AVG(Projected_Annual_Salary),2) as Avg_Proj_Annual_Salary,
	ROUND(AVG(Overtime_Pay),2) as Avg_Overtime_Pay
FROM
	Payroll
GROUP BY Dept_Title, Year
ORDER BY Dept_Title, Year;
-- Trend of decreasing pay from 2014 through 2015 then increasing in 2016

-- Looking at yearly trends between full and part time employees.
SELECT
	Year,
	Employment_Type,
	ROUND(AVG(Projected_Annual_Salary),2) as Avg_Proj_Annual_Salary,
	ROUND(AVG(Overtime_Pay),2) as Avg_Overtime_Pay
FROM
	Payroll
GROUP BY Employment_Type, Year
ORDER BY Employment_Type, Year;

-- Looking at job class title wage differences between full and part time employees.
SELECT
	Row_ID,
	YEAR,
	Dept_Title,
	Job_Class_Title,
	Employment_Type,
	Projected_Annual_Salary,
	Overtime_Pay
FROM
	Payroll
ORDER BY Dept_Title, Job_Class_Title, Year, Employment_Type;

-- Looking at projected total pay between full-time, part time, and per event employees throughout 2013 to 2016.
SELECT
	Employment_Type,
	ROUND(SUM(Projected_Annual_Salary),2) as Total_Proj_Salary_Paid
FROM
	Payroll
GROUP BY Employment_Type
ORDER BY Employment_Type;

-- Looking at projected total pay for 2013 only.
SELECT
	Employment_Type,
	ROUND(SUM(Projected_Annual_Salary),2) as Total_Proj_Salary_Paid
FROM
	Payroll
WHERE Year = 2013
GROUP BY Employment_Type
ORDER BY Employment_Type;

-- Looking at projected total pay for 2016 for comparison.
SELECT
	Employment_Type,
	ROUND(SUM(Projected_Annual_Salary),2) as Total_Proj_Salary_Paid
FROM
	Payroll
WHERE Year = 2016
GROUP BY Employment_Type
ORDER BY Employment_Type;
-- Wages expected to double between 2013 and 2016

-- Benefits

-- Looking at benefit trends throughout the years
SELECT
	Year,
	Employment_Type,
	ROUND(AVG(Average_Benefit_Cost),2) as Avg_Benefits_Cost
FROM
	Benefits
GROUP BY Employment_Type, Year
ORDER BY Employment_Type, Year;
-- Benefits seem to increase after 2015. Likely due to ACA.

SELECT
	Year,
	Employment_Type,
	ROUND(AVG(Average_Health_Cost),2) as Avg_Health_Cost,
	ROUND(AVG(Average_Dental_Cost),2) as Avg_Dental_Cost,
	ROUND(AVG(Average_Basic_Life),2) as Avg_Life_Ins_Cost,
	ROUND(AVG(Average_Benefit_Cost),2) as Avg_Benefits_Cost
FROM
	Benefits
WHERE Employment_Type = 'Full Time'
GROUP BY Year, Employment_Type
ORDER BY Employment_Type, Year;
-- Health insurance drastically increased after ACA in 2014. Dental Insurance increased moderately. Life insurance growing slowly.

-- Looking at insurance based on departments
SELECT
	Year,
	Dept_Title
	Employment_Type,
	ROUND(AVG(Average_Health_Cost),2) as Avg_Health_Cost,
	ROUND(AVG(Average_Dental_Cost),2) as Avg_Dental_Cost,
	ROUND(AVG(Average_Basic_Life),2) as Avg_Life_Ins_Cost,
	ROUND(AVG(Average_Benefit_Cost),2) as Avg_Benefits_Cost
FROM
	Benefits
WHERE Employment_Type = 'Full Time'
GROUP BY Year, Dept_Title, Employment_Type
ORDER BY Dept_Title, Year;
-- LAFD, LAPD, and DWP have highest increases for dental, 1-2% higher than other city employees.
-- City employees on the other hand had a near 5% increase in health.
-- LAPD had a 9% increase in health
-- DWP had a 12% increase in health
-- LAFP had a 1% decrease in health. Only union to see a decrease in health benefits over time.

-- Unions/No of Employees/Salary

-- Looking at most common unions within City of LA
SELECT
	ROW_NUMBER() OVER (ORDER BY COUNT(MOU) DESC) as Union_Rank,
	MOU_Title,
	COUNT(MOU) as No_Of_Emp_Union
FROM
	Benefits
GROUP BY MOU_Title, MOU
ORDER BY Union_Rank;

-- Looking at average projected annual salary per union and ordering by salary
SELECT
	ROW_NUMBER() OVER (ORDER BY AVG(p.Projected_Annual_Salary) DESC) as Salary_Rank,
	b.MOU_Title,
	COUNT(b.MOU) as No_Of_Emp_Union,
	ROUND(AVG(p.Projected_Annual_salary),2) as Avg_Proj_Salary
FROM
	Benefits b
		JOIN
	Payroll p ON b.Row_ID = p.Row_ID
GROUP BY MOU_Title, MOU
HAVING COUNT(b.MOU) > 0
ORDER BY Salary_Rank;
-- create schema creditcard;

-- use creditcard;

-- Looking at attrited customers.
SELECT 
    *
FROM
    bankchurners
WHERE
    attrition_flag LIKE 'Attr%';

-- Looking at number of attrited customers per demographics and card category
SELECT
	Attrition_Flag,
    COUNT(Education_Level) AS No_Of_Customers,
    Education_Level,
    Card_Category
FROM
	bankchurners
WHERE Attrition_Flag LIKE 'Attr%'
GROUP BY Education_Level, Card_Category
ORDER BY No_Of_Customers DESC;
-- No correlation between education level and attrition.

-- Looking at income level
SELECT
	Attrition_Flag,
	COUNT(Income_Category) as No_of_Customers_Income,
    Income_Category,
    Card_Category
FROM
	bankchurners
WHERE Attrition_Flag LIKE 'Attr%'
GROUP BY Card_Category, Income_Category
ORDER BY No_Of_Customers_Income DESC;
-- Possible correlation between lower income and card category, particularly for Blue cardholders.
-- Potential correlation between lower income and platinum attrition. No info regarding platinum card holders above $60k.

-- Looking at marital status
SELECT
	Attrition_Flag,
	COUNT(Marital_Status) as No_of_Customers,
    Marital_Status,
    Card_Category
FROM
	bankchurners
WHERE Attrition_Flag LIKE 'Attr%'
GROUP BY Card_Category, Marital_Status
ORDER BY No_Of_Customers DESC;
-- No correlation

-- Looking at no of dependents
SELECT
	Attrition_Flag,
	COUNT(Dependent_Count) as No_of_Customers_W_Dependents,
    Dependent_Count,
    Card_Category
FROM
	bankchurners
WHERE Attrition_Flag LIKE 'Attr%'
GROUP BY Card_Category, Dependent_Count
ORDER BY No_of_Customers_W_Dependents DESC;
-- No correlation.

-- Looking at customer age
SELECT
	Attrition_Flag,
	COUNT(Customer_age) as No_of_Customers,
    Customer_Age,
    Card_Category
FROM
	bankchurners
WHERE Attrition_Flag LIKE 'Attr%'
GROUP BY Card_Category, Customer_Age
ORDER BY No_of_Customers DESC;
-- Blue Card holders have higher attrition for customers between age 38 and 59.

-- Only potential correlation for attrition found within demographics is within lower income customers.

-- Looking at average credit limit and revolving balance between attrited customers and existing customers
SELECT
	Attrition_Flag,
    Card_Category,
    ROUND(AVG(Credit_Limit)) AS Avg_Credit_Limit,
    ROUND(AVG(Total_Revolving_Bal)) AS Avg_Total_Revolving_Bal,
    ROUND(AVG(Total_Revolving_Bal)/AVG(Credit_Limit),2) AS Credit_Ratio
FROM
	bankchurners
GROUP BY Attrition_Flag, Card_Category
ORDER BY Avg_Credit_Limit DESC;
-- Attrited Platinum and Blue Card holders had much lower credit utilization compared to existing cardholder counterparts.
-- Attrited and existing platinum card holders had a credit ratio differences of 0.04
-- Attrited and existing blue card holders had a credit ratio difference of 0.07
-- Gold and silver members had identical existing/attrited credit ratios 0.02.

-- Looking at total transaction amounts and counts
SELECT
	Attrition_Flag,
    Card_Category,
    ROUND(AVG(Total_Trans_Amt)) AS Avg_Trans_Amt,
    ROUND(AVG(Total_Trans_Ct)) AS Avg_Trans_Ct
FROM
	bankchurners
GROUP BY Attrition_Flag, Card_Category
ORDER BY Avg_Trans_Amt DESC;
-- Substantial difference avg transaction amt and ct between existing and attrited platinum customers.
-- More incentives may be needed to increase utilization of platinum cards.
-- Rest of the card category levels have average transaction counts between 24 and 26.

-- Looking at inactive card utilizations
SELECT
	Attrition_Flag,
    Card_Category,
    ROUND(AVG(Months_on_Book),4) AS Avg_Amt_Time_On_Books,
    ROUND(AVG(Months_Inactive_12_mon),4) AS Avg_Months_Inactive
FROM
	bankchurners
GROUP BY Attrition_Flag, Card_Category
ORDER BY Avg_Months_Inactive DESC;
-- Platinum cardholders have slightly higher amt of months going inactive.
-- Inactivity and lower utilization strong indicators of attrition.

-- Looking for lower income existing customers, within higher inactivity, lower card utilization, and lower number of transactions.
-- For blue card holders, we are also looking for existing customers ages 38 through 59.

-- Looking at existing customers who may become attrited in the future.
-- Starting with identifying all existing customers
SELECT 
    *
FROM
    bankchurners
WHERE
    attrition_flag LIKE 'Existing%';
    
-- Looking for existing blue card customers with demographic risk factors
SELECT
	CLIENTNUM,
    Card_Category,
    Customer_Age,
    Income_Category,
	ROUND((Total_Revolving_Bal/Credit_Limit),2) AS Credit_Ratio
FROM
	bankchurners
WHERE Attrition_Flag LIKE 'Existing%' 
	AND Income_Category IN ('Less than $40k', '$40k - $60k') 
    AND Card_Category = 'Blue'
    AND Customer_Age BETWEEN 38 AND 59
HAVING Credit_Ratio < 0.1
ORDER BY Credit_Ratio;
-- 650 customers identified as at-risk

-- Looking at platinum risk factors using CTE
WITH platinum_risks AS 
(SELECT
	CLIENTNUM,
    Card_Category,
    Credit_Limit,
    Total_Revolving_Bal,
    ROUND((Total_Revolving_Bal/Credit_Limit),2) AS Credit_Ratio,
    Total_Trans_Amt,
    Total_Trans_Ct,
	Months_on_Book,
    Months_Inactive_12_mon
FROM
	bankchurners
WHERE Attrition_Flag LIKE 'Existing%' 
	AND Card_Category = 'Platinum')
SELECT
	CLIENTNUM,
    Card_Category,
    Credit_Ratio,
    Total_Trans_Amt,
    Total_Trans_Ct,
    Months_on_Book,
    Months_Inactive_12_mon
FROM platinum_risks
WHERE Credit_Ratio < 0.05
	OR Total_Trans_Amt < 4756
	OR Total_Trans_Ct < 60
    OR Months_Inactive_12_mon > 3;
-- 7 platinum customers identified at risk for attrition.

-- Total of 657 blue and platinum cardholders who are at risk for attrition.
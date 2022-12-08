use Walmart;

SELECT * FROM WMT;

-- Looking at average volume traded throughout years
SELECT
	Year(Date) as 'Year',
	ROUND(AVG(Volume),0) as AvgVolume
FROM
	WMT
GROUP BY Year(Date)
ORDER BY Year(Date);

SELECT
	YEAR([Date]) as PriceYear,
	ROUND(AVG(Volume),0) AS AvgVolume,
	LAG(ROUND(AVG(Volume),0)) OVER (ORDER BY ROUND(AVG(Volume),0)) AS PrevAvgVolume,
	LEAD(ROUND(AVG(Volume),0)) OVER (ORDER BY ROUND(AVG(Volume),0)) AS NextAvgVolume,
	ROUND(ROUND(AVG(Volume),0) - LAG(ROUND(AVG(Volume),0)) OVER (ORDER BY ROUND(AVG(Volume),0)),0) AS DiffPrevVolume,
	ROUND(LEAD(ROUND(AVG(Volume),0)) OVER (ORDER BY ROUND(AVG(Volume),0)) - ROUND(AVG(Volume),0),0) AS DiffNextVolume
FROM
	WMT
GROUP BY YEAR([Date])
ORDER BY YEAR([Date]);
-- 1974 had negative avg volume difference for previous year.

-- Looking at opening price, range, and standard deviation within years
SELECT
	YEAR(Date) as WMTYear,
	ROUND(MIN([Open]),2) as LowestOpenPrice,
	ROUND(AVG([Open]),2) as AvgOpenPrice,
	ROUND(MAX([Open]),2) as HighestOpenPrice,
	ROUND(STDEV([Open]),5) as StDevOpen
FROM
	WMT
GROUP BY YEAR(Date)
ORDER BY YEAR(Date);

-- Looking at closing price, range, and standard deviation within years
SELECT
	YEAR(Date) as WMTYear,
	ROUND(MIN([Close]),2) as LowestClosePrice,
	ROUND(AVG([Close]),2) as AvgClosePrice,
	ROUND(MAX([Close]),2) as HighestClosePrice,
	ROUND(STDEV([Close]),5) as StDevClose
FROM
	WMT
GROUP BY YEAR(Date)
ORDER BY YEAR(Date);

SELECT
	YEAR([Date]) as PriceYear,
	ROUND(AVG([Open]),2) AS AvgOpenPrice,
	LAG(ROUND(AVG([Close]),2)) OVER (ORDER BY ROUND(AVG([Close]),2)) AS PrevAvgPrice,
	LEAD(ROUND(AVG([Open]),2)) OVER (ORDER BY ROUND(AVG([Open]),2)) AS NextAvgPrice,
	ROUND(ROUND(AVG([Close]),2) - LAG(ROUND(AVG([Open]),2)) OVER (ORDER BY ROUND(AVG([Open]),2)),2) AS DiffPrevOpenPrice,
	ROUND(LEAD(ROUND(AVG([Open]),2)) OVER (ORDER BY ROUND(AVG([Open]),2)) - ROUND(AVG([Close]),2),2) AS DiffNextOpenPrice
FROM
	WMT
GROUP BY Year([Date])
ORDER BY YEAR([Date]);


-- Looking at high/lows throughout years
SELECT
	YEAR(Date) as WMTYear,
	ROUND(MIN([High]),2) as LowestHighPrice,
	ROUND(MIN([Low]),2) as LowestLowPrice,
	ROUND(AVG([High]),2) as AvgHighPrice,
	ROUND(AVG([Low]),2) as AvgLowPrice,
	ROUND(MAX([High]),2) as HighestHighPrice,
	ROUND(MAX([Low]),2) as HighestLowPrice,
	ROUND(STDEV([High]/[Low]),5) as StDevHighVLow
FROM
	WMT
GROUP BY YEAR(Date)
ORDER BY YEAR(Date);

-- Looking at 7 day moving averages
SELECT
	[Date],
	[Close],
	ROUND(AVG([Close]) OVER (
		ORDER BY [Date]
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
		),7) as SevenDayMovingAvg
FROM
	WMT;

-- Looking at 30 day moving averages
SELECT
	[Date],
	[Close],
	ROUND(AVG([Close]) OVER (
		ORDER BY [Date]
		ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
		),7) as ThirtyDayMovingAvg
FROM
	WMT;


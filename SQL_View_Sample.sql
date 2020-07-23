USE [MyDATA]
GO

/****** Object:  View [dbo].[View_ServiceOnly_Scorecard]    Script Date: 4/29/2020 9:47:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_ServiceOnly_Scorecard]
AS
WITH tmp_ScoreCard
AS
(
--Get the data for contract dispatches
SELECT        [Goal Owner], YEAR([Goal Start Date]) AS [Year], MONTH([Goal Start Date]) AS [Month], 'Monthly' AS [Time Period], CONVERT(money, SUM([Goal Amount])) AS [Goal], 0 AS [Bid Count],
			  CONVERT(money, SUM([Revised Contract])) AS [Actual], 'Contracts' AS [Entity Name], [Date Type], '' AS [Lead Src], 
			  DATEFROMPARTS(YEAR([Goal Start Date]), MONTH([Goal Start Date]), 1) AS [Date Filter]
FROM            [dbo].[SERVICE_SALES_GOALS_BI]
WHERE        [Goal Category] = 'Sales Goal CY - Individual' AND [Goal Time Period] = 'Monthly' AND [Sales Group]='Contracts'
GROUP BY ROLLUP (YEAR([Goal Start Date]), MONTH([Goal Start Date]), [Goal Owner], [Date Type])

UNION ALL

SELECT        [Goal Owner], YEAR([Goal Start Date]) AS [Year], 0 AS [Month], 'Annual' AS [Time Period], CONVERT(money, SUM([Goal Amount])) AS [Goal], 0 AS [Bid Count],
			  CONVERT(money, SUM([Revised Contract])) AS [Actual], 'Contracts' AS [Entity Name], [Date Type], '' AS [Lead Src],
			  DATEFROMPARTS(YEAR([Goal Start Date]), 1, 1) AS [Date Filter]
FROM            [dbo].[SERVICE_SALES_GOALS_BI]
WHERE        [Goal Category] = 'Sales Goal CY - Individual' AND [Goal Time Period] = 'Monthly' AND [Sales Group]='Contracts'
GROUP BY ROLLUP (YEAR([Goal Start Date]), [Goal Owner], [Date Type])

UNION ALL

SELECT        [Goal Owner], YEAR([Goal Start Date]) AS [Year], 0 AS [Month], 'YTD' AS [Time Period], CONVERT(money, SUM([Goal Amount])) AS [Goal], 0 AS [Bid Count],
              CONVERT(money, SUM([Revised Contract])) AS [Actual], 'Contracts' AS [Entity Name], [Date Type], '' AS [Lead Src],
			  DATEFROMPARTS(YEAR([Goal Start Date]), 1, 1) AS [Date Filter]
FROM            [dbo].[SERVICE_SALES_GOALS_BI]
WHERE        [Goal Category] = 'Sales Goal CY - Individual' 
			AND [Sales Group]='Contracts'
			AND [Goal Time Period] = 'Monthly' 
			AND YEAR([Goal Start Date]) = YEAR(GETDATE()) 
			AND MONTH([Goal Start Date]) <= MONTH(GETDATE())
GROUP BY ROLLUP (YEAR([Goal Start Date]), [Goal Owner], [Date Type])

UNION ALL   

--Get the data for leak dispatches
SELECT        [Goal Owner], YEAR([Goal Start Date]) AS [Year], MONTH([Goal Start Date]) AS [Month], 'Monthly' AS [Time Period], CONVERT(money, SUM([Goal Amount])) AS [Goal], 0 AS [Bid Count],
			  CONVERT(money, SUM([Revised Contract])) AS [Actual], 'Leaks' AS [Entity Name], [Date Type], '' AS [Lead Src],
			  DATEFROMPARTS(YEAR([Goal Start Date]), MONTH([Goal Start Date]), 1) AS [Date Filter]
FROM            [dbo].[SERVICE_SALES_GOALS_BI]
WHERE        [Goal Category] = 'Sales Goal CY - Individual' AND [Goal Time Period] = 'Monthly' AND [Sales Group]='Leaks'
GROUP BY ROLLUP (YEAR([Goal Start Date]), MONTH([Goal Start Date]), [Goal Owner], [Date Type])

UNION ALL

SELECT        [Goal Owner], YEAR([Goal Start Date]) AS [Year], 0 AS [Month], 'Annual' AS [Time Period], CONVERT(money, SUM([Goal Amount])) AS [Goal], 0 AS [Bid Count],
		      CONVERT(money, SUM([Revised Contract])) AS [Actual], 'Leaks' AS [Entity Name], [Date Type], '' AS [Lead Src],
			  DATEFROMPARTS(YEAR([Goal Start Date]), 1, 1) AS [Date Filter]
FROM            [dbo].[SERVICE_SALES_GOALS_BI]
WHERE        [Goal Category] = 'Sales Goal CY - Individual' AND [Goal Time Period] = 'Monthly' AND [Sales Group]='Leaks'
GROUP BY ROLLUP (YEAR([Goal Start Date]), [Goal Owner], [Date Type])

UNION ALL

SELECT        [Goal Owner], YEAR([Goal Start Date]) AS [Year], 0 AS [Month], 'YTD' AS [Time Period], CONVERT(money, SUM([Goal Amount])) AS [Goal], 0 AS [Bid Count],
			  CONVERT(money, SUM([Revised Contract])) AS [Actual], 'Leaks' AS [Entity Name], [Date Type], '' AS [Lead Src],
			  DATEFROMPARTS(YEAR([Goal Start Date]), 1, 1) AS [Date Filter]
FROM            [dbo].[SERVICE_SALES_GOALS_BI]
WHERE        [Goal Category] = 'Sales Goal CY - Individual' 
			AND [Sales Group]='Leaks'
			AND [Goal Time Period] = 'Monthly' 
			AND YEAR([Goal Start Date]) = YEAR(GETDATE()) 
			AND MONTH([Goal Start Date]) <= MONTH(GETDATE())
GROUP BY ROLLUP (YEAR([Goal Start Date]), [Goal Owner], [Date Type])
)

SELECT  TOP 100 PERCENT [Goal Owner], [Year], [Month], CASE WHEN [Month] > 0 THEN CONVERT(varchar(2), FORMAT([Date Filter], 'MM')) + ' -' + FORMAT([Date Filter], 'MMM') ELSE ' ' END AS [Month Name],
		[Time Period], [Goal], [Actual], [Entity Name], [Date Type], [Bid Count], [Lead Src],
		CASE WHEN crmUser.[UserStatus] IS NULL THEN 'Active' ELSE crmUser.[UserStatus] END AS [Owner Status]
FROM  tmp_ScoreCard sc LEFT OUTER JOIN 
	  [SQLSVR].[MYCRM].[dbo].[CRM_Users] crmUser ON sc.[Goal Owner] = crmUser.[FullName] COLLATE DATABASE_DEFAULT
WHERE [Goal Owner] IS NOT NULL AND [Date Type] IS NOT NULL
ORDER BY [Goal Owner]
GO



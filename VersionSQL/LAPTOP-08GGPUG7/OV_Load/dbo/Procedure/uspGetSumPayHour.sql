/****** Object:  Procedure [dbo].[uspGetSumPayHour]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetSumPayHour] 
	-- Add the parameters for the stored procedure here
	--@payCycleGroup int, @fromDate datetime, @toDate datetime, 
	@paycycleID varchar(9), @personID varchar(9)
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @col_list VARCHAR(max)=(SELECT STUFF((SELECT ',' + '['+[Description]+']'
							FROM [LoadingRate]
							WHERE IsDeleted=0
							ORDER BY [Description]
							FOR XML PATH('')) ,1,1,''))

DECLARE @col_list_sum VARCHAR(max)=(SELECT STUFF((SELECT ',' + 'sum(['+[Description]+']) as '+ '['+[Description]+']'
							FROM [LoadingRate]
							WHERE IsDeleted=0
							ORDER BY [Description]
							FOR XML PATH('')) ,1,1,''))
--select @col_list
DECLARE @sql nvarchar(max)=
'DECLARE @paycycleID varchar(9)='''+@paycycleID+''';
DECLARE @personID varchar(9)='''+@personID+''';


SELECT * FROM (	
SELECT EmployeeID, PayrollCycleID
, sum(NormalRate) as NormalRate, sum(ToilRate) as ToilRate, NormalLoadingRate
, '+@col_list_sum+'
FROM
(
	SELECT *
	FROM (
			SELECT
			  TH.EmployeeID
			  , PC.ID as PayrollCycleID
			  ,TRA.NormalRate as NormalRate
			  ,TRA.ToilRate as ToilRate
			  ,LR.Description
			  ,TRAI.Balance as Balance
			  
			  ,lr1.Value as NormalLoadingRate
			FROM 
			  [TimesheetHeader] TH
			  LEFT JOIN [TimesheetRateAdjustment] TRA ON TH.ID = TRA.TimesheetHeaderID and TRA.IsFinalisedHours = 1
			  LEFT JOIN [TimesheetRateAdjustmentItem] TRAI ON TRA.ID = TRAI.TimesheetRateAdjustmentID
			  LEFT JOIN [LoadingRate] LR ON TRAI.RateID = LR.ID
			  INNER JOIN [PayrollCycle] PC ON TH.PayrollCycleID = PC.ID			  
			  INNER JOIN [EmployeeWorkHoursHeader] EWHH ON EWHH.ID = dbo.fnGetWorkHourHeaderIDByDay(TH.EmployeeID,PC.FromDate)
			  
			  INNER JOIN [TimesheetStatus] TS ON TH.TimesheetStatusID = TS.ID, LoadingRate lr1

			WHERE 
			  TRA.NormalRate is not null 
			  
			  AND TH.EmployeeID = cast(@personID as int) 
			  AND PC.ID=cast(@paycycleID as int)
			  
			  AND lr1.IsNormalRate=1
			  
			
	) as s
	PIVOT
	(
		SUM(Balance)
		FOR [Description] IN ('+@col_list+')
	)AS pvt
) AS Q1
GROUP BY EmployeeID, PayrollCycleID, NormalLoadingRate) As Result

'
PRINT @sql
EXEC sp_executesql @sql
 

END

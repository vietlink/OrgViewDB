/****** Object:  Procedure [dbo].[uspGetTimesheetAdjustmentForReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTimesheetAdjustmentForReport] 
	-- Add the parameters for the stored procedure here
	@empID int, @cycleID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @startDate datetime;
	DECLARE @endDate datetime;
	SELECT @startDate= pc.FromDate, @endDate= pc.ToDate
	FROM PayrollCycle pc WHERE pc.ID=@cycleID
	SELECT 
		@empID as empID, 
		@cycleID as cycleID,
		ewh.DefaultOvertimeTo,
		tra.ID as adjustmentID,
		tra.NormalRate,
		tra.ToilRate, 
		tra.IsFinalisedHours,
		tra.Comment,
		sum((isnull(trai.Balance,0))) as Balance,
		--isnull(trai.RateID,0) as RateID,
		isnull(lr.Value,0) as LoadingRate,
		isnull(tra.DisplayName,'') as DisplayName,
		th.IsPreApproved,
		isnull(c.Description,'') as costCentre,
		ts.Code as statusCode
	FROM TimesheetHeader th 
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
	INNER JOIN EmployeeWorkHoursHeader ewh ON th.EmployeeID= ewh.EmployeeID AND dbo.fnGetWorkHeaderInPeriod(@empID, @startDate, @endDate)= ewh.ID
	INNER JOIN TimesheetRateAdjustment tra ON th.ID= tra.TimesheetHeaderID
	LEFT OUTER JOIN CostCentres c ON th.CostCentreID = c.ID
	left outer join TimesheetRateAdjustmentItem trai on tra.id= trai.TimesheetRateAdjustmentID
	LEFT OUTER JOIN LoadingRate lr ON trai.RateID= lr.ID
	WHERE th.EmployeeID=@empID
	AND th.PayrollCycleID= @cycleID
	--and tra.IsFinalisedHours=0
	group by ewh.DefaultOvertimeTo, tra.id, tra.normalrate, tra.toilrate, tra.isfinalisedHours, tra.comment, lr.value, tra.displayname, th.ispreapproved, c.description, ts.code
	order by tra.IsFinalisedHours, loadingrate
END

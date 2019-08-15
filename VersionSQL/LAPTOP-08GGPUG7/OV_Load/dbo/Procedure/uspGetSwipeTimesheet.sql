/****** Object:  Procedure [dbo].[uspGetSwipeTimesheet]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspGetSwipeTimesheet 
	-- Add the parameters for the stored procedure here
	@payrollCycleID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @fromDate datetime= (SELECT pc.FromDate FROM PayrollCycle pc WHERE pc.ID= @payrollCycleID)
	DECLARE @toDate datetime= (SELECT pc.ToDate FROM PayrollCycle pc WHERE pc.ID= @payrollCycleID)
	DECLARE @payGroupID int= (SELECT pc.PayrollCycleGroupID FROM PayrollCycle pc WHERE pc.ID= @payrollCycleID)
    -- Insert statements for procedure here
	SELECT e.id as empID,
	isnull(e.PayrollID,'') as PayrollID,
	e.displayname,
	p.title,
	pc.FromDate,
	pc.ToDate,
	pc.Description,
	pc.ID as payrollCycleID,
	th.ID as timesheetID,
	isnull(dbo.fnGetTimesheetApprover(ep.id),'') AS TimesheetApprover,
	isnull(dbo.fnGetTimesheetApproverID(ep.id),0) AS TimesheetApproverID
	FROM Employee e
	LEFT OUTER JOIN EmployeePosition ep ON e.id= ep.employeeid and ep.primaryposition='Y' and ep.IsDeleted=0
	LEFT OUTER JOIN Position p ON ep.positionid= p.id
	INNER JOIN EmployeeWorkHoursHeader ewh ON e.id= ewh.EmployeeID
	INNER JOIN TimesheetHeader th ON ewh.EmployeeID= th.EmployeeID
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID AND pc.PayrollCycleGroupID= @payGroupID
	WHERE ewh.EnableSwipeCard=1
	--AND pc.ToDate<=@toDate
	and dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.FromDate)=ewh.ID and dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.ToDate)=ewh.ID 
	AND ts.Code='P'
	AND e.IsDeleted=0 and e.IsPlaceholder=0
	and th.PayrollCycleID=@payrollCycleID

END

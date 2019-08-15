/****** Object:  Procedure [dbo].[uspDeleteTimesheet]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspDeleteTimesheet] 
	-- Add the parameters for the stored procedure here
	@empID int, @payrollCycleID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @timesheetID int= (SELECT th.ID FROM TimesheetHeader th WHERE th.EmployeeID= @empID AND th.PayrollCycleID = @payrollCycleID)
	SELECT tra.ID INTO #temp FROM TimesheetRateAdjustment tra where tra.TimesheetHeaderID= @timesheetID
    -- Insert statements for procedure here
	
	DELETE FROM TimesheetDay 
	WHERE TimesheetHeaderID= @timesheetID

	DELETE FROM TimesheetStatusHistory
	WHERE TimesheetHeaderID= @timesheetID

	DELETE FROM TimesheetSummary
	where TimesheetHeaderID= @timesheetID

	DELETE FROM TimesheetComments
	WHERE TimesheetHeaderID= @timesheetID

	DELETE FROM TimesheetApproverComments 
	WHERE TimesheetHeaderID= @timesheetID

	DELETE FROM TimesheetProjectTask
	WHERE TimesheetHeaderID= @timesheetID

	DELETE FROM TimesheetBreaks
	WHERE TimesheetHeaderID= @timesheetID

	DELETE FROM TimesheetRateAdjustment
	WHERE TimesheetHeaderID= @timesheetID	

	DELETE FROM TimesheetRateAdjustmentItem
	WHERE TimesheetRateAdjustmentID IN (SELECT * FROM #temp)

	DELETE FROM TimesheetHeader
	WHERE id= @timesheetID

	EXEC dbo.uspRemoveTimesheetAccrueData @timesheetID
END

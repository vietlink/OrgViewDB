/****** Object:  Procedure [dbo].[uspRemoveTimesheetAccrueData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspRemoveTimesheetAccrueData](@timesheetId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @dateFrom datetime;
	DECLARE @empId int;
	SELECT TOP 1 @dateFrom = DateFrom, @empId = EmployeeID FROM LeaveAccrualTransactions WHERE TimesheetID = @timesheetId;
    DELETE FROM LeaveAccrualTransactions WHERE TimesheetID = @timesheetId;
	IF @empId > 0 BEGIN
		EXEC dbo.uspRegenAccrueData @dateFrom, @empId;
		EXEC dbo.uspRegenAccrueDataByTimesheet @dateFrom, @empId;
	END
END

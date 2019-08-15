/****** Object:  Procedure [dbo].[uspDoesFutureLeaveOrTimesheetExist]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspDoesFutureLeaveOrTimesheetExist](@empId int, @date datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @existingId int = 0;
	DECLARE @cancelledLeaveId int;
	SELECT @cancelledLeaveId = ID FROM LeaveStatus WHERE Code = 'C';

	SELECT @existingId = th.ID FROM TimesheetHeader th 
	INNER JOIN PayrollCycle pc ON pc.ID = th.PayrollCycleID
	WHERE th.EmployeeID = @empId AND pc.ToDate >= @date;

	IF @existingId IS NULL OR @existingId = 0 BEGIN
		SELECT @existingId = id FROM LeaveRequest WHERE DateTo >= @date AND EmployeeID = @empId AND LeaveStatusID <> @cancelledLeaveId
	END

	SELECT ISNULL(@existingId, 0) as result
    
END

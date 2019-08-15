/****** Object:  Function [dbo].[fnGetTimesheetOrScheduledHoursOnDay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetTimesheetOrScheduledHoursOnDay](@empId int, @date datetime, @leaveTypeId int)
RETURNS decimal(18,8)
AS
BEGIN
	DECLARE @hoursInDay decimal(18,8) = dbo.fnGetHoursInDay(@empId, @date);
	DECLARE @timesheetHours decimal(18,8);

	SELECT @timesheetHours = d.[Hours] FROM TimesheetDay d INNER JOIN TimesheetHeader h ON d.TimesheetHeaderID = h.ID
		WHERE h.EmployeeID  = @empId AND d.[Date] = @date;

	IF ISNULL(@timesheetHours, 0) > ISNULL(@hoursInDay, 0)
		RETURN ISNULL(@hoursInDay, 0)

	RETURN ISNULL(@timesheetHours, 0);

END


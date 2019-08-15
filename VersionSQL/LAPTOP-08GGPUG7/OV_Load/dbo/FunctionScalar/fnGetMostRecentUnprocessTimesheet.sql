/****** Object:  Function [dbo].[fnGetMostRecentUnprocessTimesheet]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Ngo Linh
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION fnGetMostRecentUnprocessTimesheet 
(
	-- Add the parameters for the function here
	@empID int
)
RETURNS datetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result datetime

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = MAX(pc.FromDate)
	FROM TimesheetHeader th 
	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
	WHERE th.EmployeeID= @empID AND th.ProcessedPayCycleID is null
	-- Return the result of the function
	RETURN @Result

END

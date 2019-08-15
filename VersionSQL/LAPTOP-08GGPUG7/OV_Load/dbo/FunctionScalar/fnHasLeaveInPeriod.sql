/****** Object:  Function [dbo].[fnHasLeaveInPeriod]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION fnHasLeaveInPeriod 
(
	-- Add the parameters for the function here
	@empID int, @fromDate datetime, @toDate datetime
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int
	DECLARE @workHeaderID int= dbo.fnGetWorkHeaderInPeriod(@empID, @fromDate, @toDate)
	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = COUNT(lr.ID)
	FROM LeaveRequest lr
	INNER JOIN LeaveRequestDetail lrd ON lr.ID= lrd.LeaveRequestID
	WHERE lrd.EmployeeWorkHoursHeaderID= @workHeaderID
	AND lrd.LeaveDateFrom>=@fromDate and lrd.LeaveDateFrom<=@toDate
	AND lr.IsCancelled=0
	-- Return the result of the function
	RETURN @Result

END

/****** Object:  Function [dbo].[fnGetTotalLeaveInPeriod]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION fnGetTotalLeaveInPeriod 
(
	-- Add the parameters for the function here
	@empID int, @fromDate datetime, @toDate datetime
)
RETURNS decimal
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result decimal

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = isnull(sum(lrd.Duration),0)
	from LeaveRequest lr 
	INNER JOIN LeaveRequestDetail lrd ON lr.id= lrd.LeaveRequestID
	INNER JOIN LeaveStatus ls ON lr.LeaveStatusID= ls.ID
	where lr.EmployeeID= @empID and lrd.LeaveDateFrom>= @fromDate and lrd.LeaveDateFrom<=@toDate
	and ls.Code='A'
	-- Return the result of the function
	RETURN @Result

END

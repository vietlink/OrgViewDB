/****** Object:  Function [dbo].[fnCountMostLeaveForEmployeeInPeriod]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnCountMostLeaveForEmployeeInPeriod] 
(
	-- Add the parameters for the function here
	@empID int, @fromDate datetime, @toDate datetime, @rejectedLeave int, @notApprovedLeave int, @leaveTypeFilter varchar(max)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	declare @leaveTypeTable table (idLeaveType varchar(max));
	IF CHARINDEX(';', @leaveTypeFilter, 0) > 0 BEGIN
		INSERT INTO @leaveTypeTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@leaveTypeFilter, ';');	
    END
    ELSE IF LEN(@leaveTypeFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @leaveTypeTable(idLeaveType) VALUES(@leaveTypeFilter);	
    END	
	DECLARE @Result int
	DECLARE @tempTable table(_date datetime, _count int)
	-- Add the T-SQL statements to compute the return value here
	INSERT INTO @tempTable
	SELECT lrd.LeaveDateFrom, (count(lr.id)) as _count
	FROM LeaveRequest lr
	INNER JOIN LeaveRequestDetail lrd ON lr.id= lrd.LeaveRequestID
	INNER JOIN LeaveStatus ls ON lr.LeaveStatusID= ls.ID
	INNER JOIN LeaveType t ON lr.LeaveTypeID= t.ID
	WHERE lr.EmployeeID= @empID
	AND lrd.LeaveDateFrom>=@fromDate AND lrd.LeaveDateFrom<=@toDate
	and lr.IsCancelled=0
	and ls.Code!='C'
	and ((ls.Code!='R'  and @rejectedLeave=0) or (@rejectedLeave=1))
	and ((ls.Code!='P' and @notApprovedLeave=0) or (@notApprovedLeave=1))
	AND ((SELECT COUNT(*) FROM @leaveTypeTable) = 0 OR t.[ReportDescription] IN (SELECT * FROM @leaveTypeTable))
	group by lrd.LeaveDateFrom
	-- Return the result of the function
	SET @Result= (SELECT max(_count) FROM @tempTable)
	RETURN @Result

END

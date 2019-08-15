/****** Object:  Function [dbo].[fnGetWorkDayData2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[fnGetWorkDayData2](@empId int, @date datetime, @currentWorkHoursHeaderID int)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		ewh.StartDateTime,
		ewh.EndDateTime,
		ISNULL(ewh.OvertimeStartsAfter, 0) AS OvertimeStartsAfter,
		ISNULL(ewh.BreakMinutes, 0) as BreakMinutes,
		ISNULL(ewh.ExtraHours, 0) as ExtraHours,
		ewh.Enabled,
		ewh.Week
	FROM
		EmployeeWorkHours ewh
	INNER JOIN
		EmployeeWorkHoursHeader ewhh
	ON
		ewh.EmployeeWorkHoursHeaderID = ewhh.ID
	WHERE 
		ewh.EmployeeID = @empID AND /* ewh.EmployeeWorkHoursHeaderID = @currentWorkHoursHeaderID
		AND */ewh.DayCode = DATENAME(dw, @date) AND ewh.[week] = dbo.fnGetWeekByHeaderDate(ewh.ID, @date)
		AND ewh.EmployeeWorkHoursHeaderID = dbo.fnGetWorkHourHeaderIDByDay(@empId, @date)
		AND @date >= ewhh.DateFrom
)


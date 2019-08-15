/****** Object:  Function [dbo].[fnGetWorkDayData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetWorkDayData](@empId int, @date datetime, @currentWorkHoursHeaderID int)
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
		ewh.Week,
		ewh.DayCode,
		ewh.DayCodeShort,
		ewh.ID,
		ewh.WorkHours,
		ewh.StartTime,
		ewh.EndTime
	FROM
		EmployeeWorkHours ewh
	INNER JOIN
		EmployeeWorkHoursHeader ewhh
	ON
		ewh.EmployeeWorkHoursHeaderID = ewhh.ID
	WHERE 
		ewh.EmployeeID = @empID AND ewh.EmployeeWorkHoursHeaderID = @currentWorkHoursHeaderID 
		AND ewh.DayCode = DATENAME(dw, @date) AND ewh.[week] = dbo.fnGetWeekByHeaderDate(@currentWorkHoursHeaderID, @date)
		AND @date >= ewhh.DateFrom
)

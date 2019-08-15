/****** Object:  Procedure [dbo].[uspGetHoursInDay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetHoursInDay](@empId int, @dayOfWeek varchar(20), @date datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @dateHeaderId int = 0;
	EXEC @dateHeaderId = dbo.uspGetWorkHourHeaderIDByDay @empId, @date
	print @dateHeaderId;
    SELECT * FROM EmployeeWorkHours ewh INNER JOIN EmployeeWorkHoursHeader ewhh ON ewh.EmployeeWorkHoursHeaderID = ewhh.ID WHERE ewh.EmployeeID = @empId AND ewh.DayCode = @dayOfWeek AND ewh.EmployeeWorkHoursHeaderID = @dateHeaderId
	AND ewh.[week] = dbo.fnGetWeekByHeaderDate(@dateHeaderId, @date)
	AND @date >= ewhh.datefrom
END

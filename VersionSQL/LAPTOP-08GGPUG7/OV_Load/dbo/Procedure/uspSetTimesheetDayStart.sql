/****** Object:  Procedure [dbo].[uspSetTimesheetDayStart]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetTimesheetDayStart](@dayId int, @time varchar(30))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime;
	DECLARE @timesheetHeaderId int;
	SELECT @date = [date], @timesheetHeaderId = TimesheetHeaderID FROM TimesheetDay WHERE ID = @dayId;
	DECLARE @empId int;
	SELECT @empId = EmployeeID FROM TimesheetHeader WHERE ID = @timesheetHeaderId

	DECLARE @headerId int;
	SELECT @headerId = dbo.fnGetWorkHourHeaderIDByDay(@empId, @date);

	DECLARE @startBuffer decimal(10,5)
	SELECT @startBuffer = StartBuffer FROM EmployeeWorkHoursHeader WHERE ID = @headerId;

	DECLARE @startDateTime datetime;
	DECLARE @enabled bit;
	SELECT @startDateTime = StartDateTime, @enabled = [Enabled] FROM dbo.fnGetWorkDayData(@empId, @date, @headerId)

	DECLARE @saveTime varchar(15) = @time;

	print @startBuffer;
	print @startDateTime

	IF ISNULL(@startBuffer, 0) > 0 AND @enabled = 1  BEGIN
		DECLARE @checkStart datetime = CAST((convert(varchar, @date, 101) + ' ' + @time) as datetime);
		DECLARE @checkEnd datetime = CAST((convert(varchar, @date, 101) + ' ' + Format(@startDateTime, 'hh:mm tt')) as datetime);
		DECLARE @diff int = DATEDIFF(minute, @checkStart, @checkEnd)

		print @checkStart
		print @diff

		IF ((@diff >= 0 AND @diff <= @startBuffer))
			SET @saveTime = LOWER(Format(@startDateTime, 'hh:mm tt'))
	END

    UPDATE TimesheetDay SET HasChanged = 1, StartTime = @saveTime, SwipeCheckIn = @time WHERE ID = @dayId;
END

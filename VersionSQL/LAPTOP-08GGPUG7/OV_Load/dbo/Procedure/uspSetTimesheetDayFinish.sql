/****** Object:  Procedure [dbo].[uspSetTimesheetDayFinish]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetTimesheetDayFinish](@dayId int, @time varchar(30))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime;
	DECLARE @timesheetHeaderId int;
	DECLARE @startTime varchar(15);

	SELECT @date = [date], @timesheetHeaderId = TimesheetHeaderID, @startTime = StartTime FROM TimesheetDay WHERE ID = @dayId;
	DECLARE @empId int;
	SELECT @empId = EmployeeID FROM TimesheetHeader WHERE ID = @timesheetHeaderId

	DECLARE @headerId int;
	SELECT @headerId = dbo.fnGetWorkHourHeaderIDByDay(@empId, @date);

	DECLARE @deductBreaks bit;
	DECLARE @deductAfter decimal(10,5);
	DECLARE @breakMinutes decimal(10,5)
	DECLARE @finishBuffer decimal(10,5)

	DECLARE @doubleSwipeBuffer decimal(10,5)
	SELECT @doubleSwipeBuffer = DoubleSwipeBuffer FROM TimesheetSettings;

	SELECT @finishBuffer = FinishBuffer, @deductAfter = DeductAfter, @deductBreaks = DeductBreaks FROM EmployeeWorkHoursHeader WHERE ID = @headerId;

	DECLARE @endDateTime datetime;
	DECLARE @enabled bit;
	SELECT @endDateTime = EndDateTime, @enabled = [Enabled], @breakMinutes = BreakMinutes FROM dbo.fnGetWorkDayData(@empId, @date, @headerId)

	DECLARE @saveTime varchar(15) = @time;

	DECLARE @checkStart datetime = CAST((convert(varchar, @date, 101) + ' ' + @time) as datetime);
	DECLARE @checkEnd datetime = CAST((convert(varchar, @date, 101) + ' ' + Format(@endDateTime, 'hh:mm tt')) as datetime);
	DECLARE @diff int = DATEDIFF(minute, @checkStart, @checkEnd)

	IF ISNULL(@finishBuffer, 0) > 0 AND @enabled = 1  BEGIN
		IF ((-@diff >= 0 AND -@diff <= @finishBuffer))
			SET @saveTime = LOWER(Format(@endDateTime, 'hh:mm tt'))
	END

	DECLARE @swipeInTime varchar(15);
	SELECT @swipeInTime = SwipeCheckIn FROM TimesheetDay WHERE ID = @dayId;

	IF ISNULL(@doubleSwipeBuffer, 0) > 0 BEGIN
		DECLARE @swipeCheckStart datetime = CAST((convert(varchar, @date, 101) + ' ' + @swipeInTime) as datetime);
		DECLARE @swipeCheckEnd datetime = CAST((convert(varchar, @date, 101) + ' ' + @time) as datetime);
		DECLARE @swipeDiff int = DATEDIFF(minute, @swipeCheckStart, @swipeCheckEnd)

		IF ((-@swipeDiff >= 0 AND -@swipeDiff <= @doubleSwipeBuffer) OR (@swipeDiff >= 0 AND @swipeDiff <= @doubleSwipeBuffer))
			RETURN;
	END

	DECLARE @compareStart datetime = CAST((convert(varchar, @date, 101) + ' ' + @swipeInTime) as datetime)
	DECLARE @compareFinish datetime = CAST((convert(varchar, @date, 101) + ' ' + @saveTime) as datetime)

	IF CHARINDEX('pm', LOWER(@startTime)) > 0 AND CHARINDEX('am', LOWER(@saveTime)) > 0 BEGIN
		SET @compareFinish = DATEADD(day, 1, @compareFinish)
	END
	

	DECLARE @setMinutes decimal(10,5);
	SELECT @setMinutes = SUM([Minutes]) FROM TimesheetBreaks WHERE [Date] = @date AND TimesheetHeaderID = @timesheetHeaderID

	DECLARE @hours decimal(10,5) = DATEDIFF(minute, @compareStart, @compareFinish) / 60.0
	DECLARE @overtimeAfter decimal(10,5) = dbo.fnGetOvertimeAfterOnDay(@empId, @date);
	DECLARE @actualOvertime decimal(10,5) = 0;

	IF @deductBreaks = 1 AND @hours >= @deductAfter BEGIN
		IF ISNULL(@setMinutes, 0) < ISNULL(@breakMinutes, 0)
			SET @setMinutes = ISNULL(@setMinutes, 0) + ISNULL(@breakMinutes, 0)
	END

	IF @setMinutes > 0
		SET @hours = (DATEDIFF(minute, @compareStart, @compareFinish) - (@setMinutes)) / 60.0

	IF @hours > @overtimeAfter
		SET @actualOvertime = (@hours - @overtimeAfter);


    UPDATE TimesheetDay SET HasChanged = 1, FinishTime = @saveTime, SwipeCheckOut = @time, [Hours] = @hours, [Breaks] = ISNULL(@setMinutes,0), DailyOvertime = @actualOvertime WHERE ID = @dayId;
END

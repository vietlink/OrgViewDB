/****** Object:  Function [dbo].[fnGetWeekByHeaderDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetWeekByHeaderDate](@headerId int, @date datetime)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @profileStart DateTime
	DECLARE @weekMode int
	DECLARE @pcGroupId int;
	SELECT @profileStart = [DateFrom], @pcGroupId = PayRollCycle, @weekMode = WeekMode FROM EmployeeWorkHoursHeader where ID = @headerId;

	DECLARE @startDayIndex int;
	SELECT @startDayIndex = StartDayIndex FROM PayrollCycleGroups WHERE ID = @pcGroupId;
	
	IF @weekMode = 1
		RETURN 1;

	DECLARE @profileStartWeek int;
	DECLARE @dateWeek int;
			
	IF @startDayIndex > 1 BEGIN
		SET @date = DATEADD(day, -(@startDayIndex), @date);
	END

	SELECT @profileStartWeek = DATEPART(wk, @profileStart)
	SELECT @dateWeek = DATEPART(wk, @date)

	IF (@profileStartWeek % 2) = (@dateWeek % 2)
		RETURN 1;

	RETURN 2;
END



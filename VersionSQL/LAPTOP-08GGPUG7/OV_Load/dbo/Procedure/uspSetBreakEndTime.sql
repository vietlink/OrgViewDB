/****** Object:  Procedure [dbo].[uspSetBreakEndTime]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetBreakEndTime](@breakId int, @time varchar(10), @minutes decimal(10,5))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE TimesheetBreaks SET EndTime = @time, [Minutes] = @minutes WHERE ID = @breakId;
	DECLARE @date datetime;
	DECLARE @timesheetHeaderId int;
	SELECT @date = [date], @timesheetHeaderId = TimesheetHeaderID FROM TimesheetBreaks WHERE ID = @breakId;

	UPDATE TimesheetDay SET Breaks = (SELECT SUM(minutes) FROM TimesheetBreaks WHERE [date] = @date AND TimesheetHeaderID = @timesheetHeaderId)
		WHERE TimesheetHeaderID = @timesheetHeaderId AND [date] = @date;
END


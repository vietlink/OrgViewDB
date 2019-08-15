/****** Object:  Procedure [dbo].[uspUpdateTimeDayHours]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateTimeDayHours](@dayId int, @hours decimal(10,5), @overtime decimal(10,5))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE TimesheetDay SET Hours = @hours, DailyOvertime = @overtime WHERE ID = @dayId
END


/****** Object:  Procedure [dbo].[uspAddTimesheetSwipeEntry]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddTimesheetSwipeEntry](@empId int, @time datetime, @mode int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO TimesheetSwipeEntries(EmployeeID, [Time], [Mode])
		VALUES(@empId, @time, @mode)
END


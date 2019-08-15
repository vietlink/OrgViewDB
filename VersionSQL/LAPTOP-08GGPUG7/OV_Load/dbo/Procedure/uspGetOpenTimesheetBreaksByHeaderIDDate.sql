/****** Object:  Procedure [dbo].[uspGetOpenTimesheetBreaksByHeaderIDDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOpenTimesheetBreaksByHeaderIDDate](@headerId int, @date datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 1 * FROM TimesheetBreaks WHERE TimesheetHeaderID = @headerId AND [date] = @date AND (EndTime IS NULL or EndTime = '')
	ORDER BY ID DESC
END


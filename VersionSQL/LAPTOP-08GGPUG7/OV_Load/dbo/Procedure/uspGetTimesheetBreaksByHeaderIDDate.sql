/****** Object:  Procedure [dbo].[uspGetTimesheetBreaksByHeaderIDDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTimesheetBreaksByHeaderIDDate](@headerId int, @date datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM TimesheetBreaks WHERE TimesheetHeaderID = @headerId AND [date] = @date;
END


/****** Object:  Procedure [dbo].[uspGetTimesheetDay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTimesheetDay](@headerId int, @date DateTime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM TimesheetDay WHERE TimesheetHeaderID = @headerId AND [Date] = @date
END


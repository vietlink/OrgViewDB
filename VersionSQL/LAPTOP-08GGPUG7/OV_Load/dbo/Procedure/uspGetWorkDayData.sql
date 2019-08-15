/****** Object:  Procedure [dbo].[uspGetWorkDayData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetWorkDayData](@empId int, @date datetime, @workHoursHeaderId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM dbo.fnGetWorkDayData(@empId, @date, @workHoursHeaderId)
END


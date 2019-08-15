/****** Object:  Procedure [dbo].[uspGetOvertimeAfterOnDay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOvertimeAfterOnDay](@empId int, @date datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @currentHeader int = dbo.fnGetWorkHourHeaderIDByDay(@empId, @date);
	SELECT ISNULL(OvertimeStartsAfter, 0) FROM dbo.fnGetWorkDayData(@empId, @date, @currentHeader);
END


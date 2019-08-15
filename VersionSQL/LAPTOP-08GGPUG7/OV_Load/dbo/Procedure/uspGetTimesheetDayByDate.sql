/****** Object:  Procedure [dbo].[uspGetTimesheetDayByDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[uspGetTimesheetDayByDate](@empId int, @date datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		*
	FROM
		TimesheetHeader th
	INNER JOIN 
		TimesheetDay td
	ON
		th.ID = td.TimesheetHeaderID
	WHERE
		th.EmployeeID = @empId AND td.[Date] = @date;



END

/****** Object:  Procedure [dbo].[uspDoesLeaveExistInRange]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspDoesLeaveExistInRange](@empId int, @workHeaderID int, @dateFrom datetime, @dateTo datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM LeaveRequest WHERE EmployeeID = @empID AND EmployeeWorkHoursHeaderID= @workHeaderID and IsCancelled=0
	AND ((dateFrom >= @dateFrom AND dateFrom <= @dateTo) OR (dateTo >= @dateFrom AND dateTo <= @dateTo))
END


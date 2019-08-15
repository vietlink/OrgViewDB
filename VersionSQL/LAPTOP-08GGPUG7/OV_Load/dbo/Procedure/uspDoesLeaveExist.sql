/****** Object:  Procedure [dbo].[uspDoesLeaveExist]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspDoesLeaveExist](@empId int, @workHeaderID int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM LeaveRequest WHERE EmployeeID = @empID AND EmployeeWorkHoursHeaderID= @workHeaderID and IsCancelled=0
END

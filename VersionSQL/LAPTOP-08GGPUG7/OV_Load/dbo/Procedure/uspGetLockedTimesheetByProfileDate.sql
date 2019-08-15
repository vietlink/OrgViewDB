/****** Object:  Procedure [dbo].[uspGetLockedTimesheetByProfileDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetLockedTimesheetByProfileDate](@empId int, @date datetime, @headerId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 1
		pc.ToDate as TimesheetDate 
	FROM
		TimesheetHeader th
	INNER JOIN
		PayrollCycle pc
	ON
		pc.ID = th.PayrollCycleID
	WHERE
		th.EmployeeID = @empId AND th.ProcessedPayCycleID IS NOT NULL AND pc.ToDate >= @date AND th.ID <> @headerId
	ORDER BY pc.ToDate DESC

END

/****** Object:  Procedure [dbo].[uspUpdateTimesheetCostCentreByProfileId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateTimesheetCostCentreByProfileId](@employeeWorkHoursHeaderId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @dateFrom datetime;
	DECLARE @dateTo datetime;
	DECLARE @empId int;
	DECLARE @costCentreId int;

	SELECT @empId = EmployeeID, @dateFrom = DateFrom, @dateTo = ISNULL(DateTo, '2222-01-01'), @costCentreId = PayCostCentreID FROM EmployeeWorkHoursHeader WHERE ID = @employeeWorkHoursHeaderId;

	UPDATE
		ts
	SET
		ts.CostCentreID = @costCentreId
	FROM
		TimesheetHeader ts
	INNER JOIN
		PayrollCycle pc
	ON
		pc.ID = ts.PayrollCycleID
	WHERE
		EmployeeID = @empID AND
		ProcessedPayCycleID IS NULL AND
		pc.FromDate >= @dateFrom AND pc.FromDate <= @dateTo;



END


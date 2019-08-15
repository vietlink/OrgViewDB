/****** Object:  Procedure [dbo].[uspCreateTimesheetHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspCreateTimesheetHeader](@employeeId int, @payrollCycleId int, @createdBy varchar(255),
	@workedHours decimal(10,5), @leaveHours decimal(10,5), @totalHours decimal(10,5), @overtimeHours decimal(10,5), @createdByEmpId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @statusId int;
	SELECT @statusId = ID FROM TimesheetStatus WHERE code = 'P';
	DECLARE @retId int = 0;
	SELECT @retId = ID FROM TimesheetHeader WHERE EmployeeID = @employeeId AND PayrollCycleID = @payrollCycleId

	DECLARE @dateFrom datetime;
	DECLARE @dateTo datetime;

	SELECT @dateFrom = fromDate, @dateTo = toDate FROM PayrollCycle WHERE id = @payrollCycleId

	DECLARE @workHoursHeaderId int;
	SELECT @workHoursHeaderId = dbo.fnGetWorkHourHeaderIDByDay(@employeeId, @dateFrom);
	IF ISNULL(@workHoursHeaderId, 0) = 0
		SELECT @workHoursHeaderId = dbo.fnGetTopWorkProfileID(@employeeId);
	DECLARE @ccId int = 0;
	SELECT @ccId = PayCostCentreID FROM EmployeeWorkHoursHeader WHERE ID = @workHoursHeaderId

	IF @retId < 1 BEGIN
		INSERT INTO TimesheetHeader(EmployeeID, PayrollCycleID, TimesheetStatusID, CreatedBy, CreatedDate,
			ContractedHours, WorkedHours, LeaveHours, TotalHours, OvertimeHours, ToilHours, LastUpdated, CostCentreID)
			VALUES(@employeeId, @payrollCycleId, @statusId, @createdBy, GETDATE(),
			dbo.fnGetWorkHoursInRage(@employeeId, @dateFrom, @dateTo), @workedHours, @leaveHours, @totalHours, @overtimeHours, 0, GETDATE(), @ccId);

		SET @retId = @@IDENTITY;

		INSERT INTO TimesheetStatusHistory(ApproverEmployeeID, TimesheetHeaderID, [Date], TimesheetStatusID)
			VALUES(@createdByEmpId, @retId, GETDATE(), @statusId);

		IF @createdBy = 'Swipe System' BEGIN
			DECLARE @dateScan datetime = @dateFrom;

			WHILE @dateScan <= @dateTo BEGIN
				DECLARE @enabled bit = 0;
				SELECT @enabled = [Enabled] FROM dbo.fnGetWorkDayData(@employeeId, @dateScan, @workHoursHeaderId);

				IF @enabled = 1 BEGIN
					INSERT INTO TimesheetDay(TimesheetHeaderID, [Date], StartTime, FinishTime, Breaks, [Hours], HasChanged, DailyOvertime)
						VALUES(@retId, @dateScan, '', '', 0, 0, 0, 0);
				END

				SET @dateScan = DATEADD(day, 1, @dateScan);
			END
		END
	END
	ELSE BEGIN
		UPDATE 
			TimesheetHeader 
		SET 
			LastUpdated = GETDATE(),
			WorkedHours = @workedHours,
			LeaveHours = @leaveHours,
			TotalHours = @totalHours,
			OvertimeHours = @overtimeHours,
			ContractedHours = dbo.fnGetWorkHoursInRage(@employeeId, @dateFrom, @dateTo),
			CostCentreID = @ccId
		WHERE ID = @retId;
	END


	IF NOT EXISTS (SELECT ID FROM TimesheetStatusHistory WHERE TimesheetHeaderID = @retId AND TimesheetStatusID = @statusId) BEGIN
		INSERT INTO TimesheetStatusHistory(ApproverEmployeeID, TimesheetHeaderID, [Date], TimesheetStatusID)
			VALUES(@createdByEmpId, @retId, GETDATE(), @statusId);
	END

	DECLARE @submitId int;
	SELECT @submitId = ID FROM TimesheetStatus WHERE Code = 's';

	IF NOT EXISTS (SELECT ID FROM TimesheetHeader WHERE ID = @retId AND (TimesheetStatusID = @submitId OR TimesheetStatusID = @statusId) AND IsTimesheetApproved = 0 AND IsAdditionalApproved = 0) BEGIN
		UPDATE
			TimesheetHeader
		SET
			TimesheetStatusID = @statusId,
			IsTimesheetApproved = 0,
			IsAdditionalApproved = 0
		WHERE
			ID = @retId

		EXEC dbo.uspRemoveTimesheetAccrueData @retId
		EXEC dbo.uspRemoveTimesheetTOIL @retId
	END

	RETURN @retId;
END

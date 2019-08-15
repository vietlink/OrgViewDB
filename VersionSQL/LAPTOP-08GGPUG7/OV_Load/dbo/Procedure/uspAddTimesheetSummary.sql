/****** Object:  Procedure [dbo].[uspAddTimesheetSummary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddTimesheetSummary](@timesheetHeaderId int, @normalHours decimal(18,10), @workedHours decimal(18,10), @paidLeaveHours decimal(18,10),
	@total decimal(18, 10), @overtime decimal(18, 10), @unpaidLeaveHours decimal(18, 10), @overtimeStartsAfter decimal(18,10), @plannedWorkHours decimal(18,10), @extraHoursWorked decimal(18,10), @week int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DELETE FROM TimesheetSummary WHERE TimesheetHeaderID = @timesheetHeaderId AND ISNULL([Week], 0) = ISNULL(@week, 0)

	DECLARE @paycycleId int;
	DECLARE @empID int
	SELECT @paycycleId = PayrollCycleID, @empID = EmployeeID FROM TimesheetHeader WHERE ID = @timesheetHeaderId
	DECLARE @date datetime;
	SELECT @date = FromDate FROM PayrollCycle WHERE ID = @paycycleId

	DECLARE @profileId int = dbo.fnGetWorkHourHeaderIDByDay(@empId, @date);

	DECLARE @defaultOvertimeTo int;
	DECLARE @extraHoursPayType int;
	DECLARE @normalovertimerate int; -- rate id

	SELECT @defaultOvertimeTo = defaultOvertimeTo, @extraHoursPayType = extraHoursPayType, @normalovertimerate = NormalOvertimeRate FROM EmployeeWorkHoursHeader WHERE ID = @profileId;	
	
	IF @week IS NULL BEGIN
		IF @defaultOvertimeTo = 2 AND @overtime > 0 BEGIN -- toil/overtime
			print @defaultOvertimeTo
			UPDATE TimesheetHeader SET RequiresAdditionalApproval = 1 WHERE ID = @timesheetHeaderId
		END

		IF @extraHoursPayType = 1 AND @extraHoursWorked > 0 BEGIN -- extra hours toil
			print @extraHoursPayType;
			UPDATE TimesheetHeader SET RequiresAdditionalApproval = 1 WHERE ID = @timesheetHeaderId
		END
	END
	INSERT INTO TimesheetSummary(TimesheetHeaderID, NormalHours, WorkedHours, PaidLeaveHours, Total, Overtime, UnpaidLeaveHours, OvertimeStartsAfter, PlannedWorkHours, ExtraHoursWorked, [Week], OvertimeRateID)
		VALUES(@timesheetHeaderId, @normalHours, @workedHours, @paidLeaveHours, @total, @overtime, @unpaidLeaveHours, @overtimeStartsAfter, @plannedWorkHours, @extraHoursWorked, @week, @normalovertimerate)
END

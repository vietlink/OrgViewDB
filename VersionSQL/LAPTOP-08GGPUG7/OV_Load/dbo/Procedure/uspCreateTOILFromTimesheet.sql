/****** Object:  Procedure [dbo].[uspCreateTOILFromTimesheet]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspCreateTOILFromTimesheet](@headerId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @toilRate decimal(10, 5);
	SELECT @toilRate = ToilRate FROM TimesheetRateAdjustment WHERE TimesheetHeaderID = @headerId AND IsFinalisedHours  = 1
	DECLARE @accrueTypeId int;
	SELECT @accrueTypeId = ID FROM LeaveTransactionTypes WHERE Code = 'A';

	IF ISNULL(@toilRate, 0) > 0 BEGIN
		DECLARE @payrollCycleId int = 0;
		DECLARE @empId int = 0;
		SELECT @payrollCycleId = PayrollCycleID, @empId = EmployeeID FROM TimesheetHeader WHERE ID = @headerId;
		
		DECLARE @date datetime;
		SELECT @date = ToDate FROM PayrollCycle WHERE ID = @payrollCycleId

		DECLARE @toilTypeId int = 0;
		DECLARE @maxBalance decimal(18,10) = 0;

		SELECT @toilTypeId = ID, @maxBalance = MaxAccruedBalance FROM LeaveType WHERE SystemCode = 'TOIL';

		DECLARE @adjustmentId int = 0;
		SELECT @adjustmentId = ID FROM LeaveTransactionTypes WHERE Code = 'A';

		DECLARE @currentBalance decimal(18,10);
		SET @currentBalance = dbo.fnGetTotalAccrualCount2(@date, @empId, @toilTypeId, 0)

		IF ISNULL(@maxBalance, 0) > 0 AND (@currentBalance + @toilRate) > @maxBalance BEGIN
			SET @toilRate = @maxBalance - @currentBalance;
			IF @toilRate < 0
				SET @toilRate = 0;
		END
		
		IF NOT EXISTS (SELECT ID FROM LeaveAccrualTransactions WHERE EmployeeID = @empId AND LeaveTypeID = @toilTypeId AND DateFrom = @date AND TransactionTypeID = @accrueTypeId) BEGIN
			INSERT INTO LeaveAccrualTransactions(EmployeeID, LeaveTypeID, DateFrom, DateTo, TransactionTypeID, Balance, Taken, Adjustment, PayrollCycleID)
				VALUES(@empId, @toilTypeId, @date, @date, @adjustmentId, @currentBalance, NULL, @toilRate, @payrollCycleId)
			UPDATE
				LeaveAccrualTransactions
			SET
				Balance = dbo.fnGetTotalAccrualCount2(DateFrom, EmployeeID, LeaveTypeID, 0)
			WHERE
				EmployeeID = @empId AND LeaveTypeID = @toilTypeId
				
		END

	END
END

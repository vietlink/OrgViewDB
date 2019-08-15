/****** Object:  Procedure [dbo].[uspGenerateAccrueDataByTimesheet]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGenerateAccrueDataByTimesheet](@timesheetId int, @preventRegen int = 0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @empId int = 0;
	DECLARE @payrollCycleId int = 0;
	DECLARE @toilId int = 0;

	SELECT @toilId = id FROM LeaveType WHERE SystemCode = 'TOIL'

	SELECT @empId = EmployeeID, @payrollCycleId = PayrollCycleID FROM TimesheetHeader WHERE ID = @timesheetId;
    
	DECLARE @dateFrom datetime;
	DECLARE @dateTo datetime;

	SELECT @dateFrom = FromDate, @dateTo = ToDate FROM PayrollCycle WHERE ID = @payrollCycleId

	DECLARE @headerId int = 0;
	SET @headerId = dbo.fnGetWorkHourHeaderIDByDay(@empId, @dateFrom);

	DECLARE leaveTypeCursor CURSOR  
		FOR SELECT lt.ID, lt.AccrueAfterDays, lt.ZeroBalanceEnabled, lt.ZeroBalanceDay, lt.ZeroBalanceMonth, lt.AccrueInAdvanced, lt.MaxAccruedBalance FROM LeaveType lt
		INNER JOIN
		EmployeeLeaveTypes elt
		ON elt.LeaveTypeID = lt.ID
		WHERE lt.AccrueLeave = 1 AND elt.[Enabled] = 1 AND elt.EmployeeID  = @empId AND elt.EmployeeWorkHoursHeaderID = @headerId AND lt.ID <> @toilId
	OPEN leaveTypeCursor  

	DECLARE @leaveTypeId int;
	DECLARE @accrueAfterDays int;
	DECLARE @zeroBalance bit;
	DECLARE @zeroBalanceDay int;
	DECLARE @zeroBalanceMonth int;
	DECLARE @accrueInAdvanced bit;
	DECLARE @maxAccruedBalance decimal(10,5);

	DECLARE @accruedTransactionId int;
	SELECT @accruedTransactionId = id FROM LeaveTransactionTypes WHERE code = 'A';

	DECLARE @adjustmentId int;
	SELECT @adjustmentId = id FROM LeaveTransactionTypes WHERE code = 'CA';

	DECLARE @commencement DateTime;
	SELECT @commencement = commencement FROM Employee WHERE id = @empId;

	DECLARE @currentDay int;
	DECLARE @currentMonth int;
	
	DELETE FROM LeaveAccrualTransactions WHERE TimesheetID = @timesheetId

	FETCH NEXT FROM leaveTypeCursor INTO @leaveTypeId, @accrueAfterDays, @zeroBalance, @zeroBalanceDay, @zeroBalanceMonth, @accrueInAdvanced, @maxAccruedBalance

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE FROM LeaveAccrualTransactions WHERE ([DateFrom] >= @dateFrom AND [DateFrom] <= @dateTo) AND EmployeeID = @empId AND TransactionTypeID = @accruedTransactionId AND LeaveTypeID = @leaveTypeId AND TimesheetID IS NULL
		DECLARE @exists int = 0;

		DECLARE @newBalance decimal(18,10) = 0;
		DECLARE @currentBalance decimal(25,15) = 0;
		DECLARE @currentDate datetime = @dateFrom;

		DECLARE @totalWorked decimal(18,10);
		DECLARE @normalHours decimal(18,10);

		SELECT @totalWorked = (total - extrahoursworked), @normalHours = overtimeStartsAfter FROM TimesheetSummary WHERE TimesheetHeaderID = @timesheetId AND [Week] IS NULL

		DECLARE @workedHours decimal(18, 10)
		IF @totalWorked > @normalHours
			SET @workedHours = @normalHours;
		ELSE
			SET @workedHours = @totalWorked

		DECLARE @dailyAccrueRate decimal(25, 15);
		SELECT @dailyAccrueRate = dbo.fnGetAccrueHoursByLeaveType(@leaveTypeId);

		DECLARE @value decimal(25, 15) = @dailyAccrueRate * @workedHours;
		DECLARE @balance decimal(25, 15);
		SET @currentBalance = dbo.fnGetTotalAccrualCount2(@dateTo, @empId, @leaveTypeId, 0);
		
		IF ((@currentBalance + @value) < @maxAccruedBalance) OR ISNULL(@maxAccruedBalance, 0) = 0 
		BEGIN
		--	IF dbo.fnCheckNoAccruelLeaveBooked(@currentDate, @leaveTypeId, @empId) = 0 BEGIN
				IF ISNULL(@workedHours, 0) > 0 BEGIN

					SET @balance = dbo.fnGetTotalAccrualCount2(@dateTo, @empId, @leaveTypeId, 0);
										
					SET @newBalance += @value;
				END
		--	END
		END
		ELSE IF (@currentBalance < @maxAccruedBalance) AND ISNULL(@dailyAccrueRate, 0) > 0 BEGIN
			DECLARE @fillValue decimal(25, 15);
			SET @fillValue = @maxAccruedBalance - @currentBalance;
			SET @balance = dbo.fnGetTotalAccrualCount2(@dateTo, @empId, @leaveTypeId, 0);

			IF ((@accrueAfterDays IS NULL OR @accrueAfterDays = 0) OR @currentDate >= DATEADD (day, @accrueAfterDays,@commencement))
			AND NOT EXISTS (SELECT ID FROM LeaveAccrualTransactions WHERE EmployeeID = @empId
				AND LeaveTypeID = @leaveTypeId AND DateFrom = @currentDate AND DateTo = @currentDate AND TransactionTypeID = @accruedTransactionId) BEGIN
					SET @newBalance += @fillValue;
			END
		END
		IF @zeroBalance = 1 AND @zeroBalanceDay IS NOT NULL AND @zeroBalanceMonth IS NOT NULL BEGIN
			IF @zeroBalanceDay = @currentDay AND @zeroBalanceMonth = @currentMonth BEGIN
				IF NOT EXISTS (SELECT ID FROM LeaveAccrualTransactions WHERE EmployeeID = @empID AND LeaveTypeID = @leaveTypeId AND TransactionTypeID = @adjustmentId AND DateFrom = @currentDate) BEGIN
					DECLARE @newTaken decimal(10,5) = dbo.fnGetTotalAccrualCount2(@dateTo, @empId, @leaveTypeId, 0);
				
					INSERT INTO
						LeaveAccrualTransactions(EmployeeID, LeaveTypeID, DateFrom, DateTo, TransactionTypeID,
						Balance, Taken, Adjustment, Comment, Mode, LeaveRequestID, TimesheetID)
					VALUES(
						@empId, @leaveTypeId, @currentDate, @currentDate, @adjustmentId, 0, @newTaken, 0, '', 'Expired', 0, @timesheetId
					)
				END
			END
		END
		
		IF @newBalance > 0 BEGIN
			INSERT INTO LeaveAccrualTransactions(EmployeeID, LeaveTypeID, DateFrom, DateTo, TransactionTypeID,
				Balance, Taken, Adjustment, Mode, TimesheetID)
			VALUES(@empId, @leaveTypeId, @dateFrom, @dateTo, @accruedTransactionId, (@currentBalance + @newBalance), null, @newBalance, 'Automatic', @timesheetId)
		END

		FETCH NEXT FROM leaveTypeCursor INTO @leaveTypeId, @accrueAfterDays, @zeroBalance, @zeroBalanceDay, @zeroBalanceMonth, @accrueInAdvanced, @maxAccruedBalance
	END

	CLOSE leaveTypeCursor;
	DEALLOCATE leaveTypeCursor;

	IF @preventRegen = 0 BEGIN
		EXEC uspRegenAccrueDataByTimesheet @dateTo, @empId;
	END
END

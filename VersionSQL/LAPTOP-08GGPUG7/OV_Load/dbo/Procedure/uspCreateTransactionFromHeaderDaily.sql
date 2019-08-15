/****** Object:  Procedure [dbo].[uspCreateTransactionFromHeaderDaily]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspCreateTransactionFromHeaderDaily](@headerId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	exec uspCancelTransactions @headerId;

	DECLARE @EmployeeID int;
	DECLARE @LeaveTypeID int;
	DECLARE @DateFrom datetime;
	DECLARE @DateTo datetime;
	DECLARE @Balance decimal(18,8);
	DECLARE @Taken decimal(18,8);
	SELECT @EmployeeID = EmployeeID, @LeaveTypeID = LeaveTypeID, @DateFrom = DateFrom, @DateTo = DateTo
	FROM LeaveRequest WHERE id = @headerId;

	DECLARE @TakenTypeID int;
	SELECT @TakenTypeID = id FROM LeaveTransactionTypes WHERE Code = 'T';

	set @Taken = dbo.fnGetHoursFromLeaveRequest(@EmployeeID, @headerId);
	set @Balance = dbo.fnGetTotalAccrualCount2(@DateFrom, @EmployeeID, @LeaveTypeID, @TakenTypeID);
	set @Balance = @Balance - @Taken;
	
	UPDATE 
		LeaveAccrualTransactions 
	SET
		Balance = Balance - @Taken
	WHERE
		EmployeeID = @EmployeeID 
		AND LeaveTypeID = @LeaveTypeID
		AND DateFrom >= @DateFrom

	--fnGetLeaveHoursOnDayByHeader

	DECLARE @scanDate datetime = @DateFrom;
	WHILE @scanDate <= @DateTo BEGIN
		--DELETE FROM LeaveAccrualTransactions WHERE EmployeeID = @EmployeeID AND DateFrom = @scanDate AND TransactionTypeID = @TakenTypeID
		DECLARE @hours decimal(18,2) = dbo.fnGetLeaveHoursOnDayByHeader(@headerId, @scanDate);
		DECLARE @dayBalance decimal(18,8) = dbo.fnGetTotalAccrualCount2(@scanDate, @EmployeeID, @LeaveTypeID, @TakenTypeID);
		SET @dayBalance = @dayBalance - @hours;
		IF @hours > 0 BEGIN
		INSERT INTO 
			LeaveAccrualTransactions(EmployeeID, LeaveTypeID, DateFrom, DateTo, TransactionTypeID, Balance,
				Taken, Adjustment, Mode, LeaveRequestID)
				VALUES(@EmployeeID, @LeaveTypeID, @scanDate, @scanDate, @TakenTypeID, @dayBalance, @hours, 0.0, 'Automatic', @headerId);
		END
		SET @scanDate = DATEADD(DAY, 1, @scanDate);
	END
		
	--INSERT INTO 
	--	LeaveAccrualTransactions(EmployeeID, LeaveTypeID, DateFrom, DateTo, TransactionTypeID, Balance,
	--		Taken, Adjustment, Mode, LeaveRequestID)
	--VALUES(@EmployeeID, @LeaveTypeID, @DateFrom, @DateTo, @TakenTypeID, @Balance, @Taken, 0.0, 'Automatic', @headerId);

	-- Check if any transactions were created which do not support this leave type
	DECLARE @nonSupportedTypes TABLE (id int);
	INSERT INTO @nonSupportedTypes SELECT SupportedLeaveTypeID FROM LeaveSupportedAccrueTypes WHERE LeaveTypeId = @leaveTypeId AND AccrueLeave = 0;

	DECLARE @accrueType int;
	SELECT @accrueType = id FROM LeaveTransactionTypes WHERE code = 'A';

	DECLARE @count int = 0;

	SELECT @count = COUNT(*) FROM LeaveAccrualTransactions WHERE EmployeeID = @employeeID AND TransactionTypeID = @accrueType AND
		(DateFrom >= @DateFrom AND DateFrom <= @DateTo) AND LeaveTypeID IN (SELECT ID FROM @nonSupportedTypes) AND TimesheetID IS NULL

	IF @count > 0 BEGIN
		DELETE FROM LeaveAccrualTransactions WHERE EmployeeID = @employeeID AND TransactionTypeID = @accrueType AND
		(DateFrom >= @DateFrom AND DateFrom <= @DateTo) AND LeaveTypeID IN (SELECT ID FROM @nonSupportedTypes) AND TimesheetID IS NULL
		DECLARE @dayLess datetime = DATEADD(day, -1, @DateFrom)
		EXEC dbo.uspRegenAccrueData @dayLess, @EmployeeID
	END
END

/****** Object:  Procedure [dbo].[uspAddEmployeeToLeaveAdjustmentHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddEmployeeToLeaveAdjustmentHeader](@empId int, @headerId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	INSERT INTO LeaveAdjustmentPeople(EmployeeID, LeaveAdjustmentHeaderID)
		VALUES(@empId, @headerId)

	DECLARE @credit decimal(25,15);
	DECLARE @debit decimal(25,15);
	DECLARE @date DateTime;
	DECLARE @leaveTypeId int;
		
	SELECT @leaveTypeId = leavetypeid, @credit = CreditAmount, @debit = DebitAmount, @date = [Date] FROM LeaveAdjustmentHeader WHERE ID = @headerId;

	--DECLARE @workedHours decimal(18,8) = 0;
	--SELECT @workedHours = dbo.fnGetWorkedAccruableHours(@empId, @date, @leaveTypeId);
		
	--DECLARE @dailyAccrueRate decimal(25, 15);
	--SELECT @dailyAccrueRate = dbo.fnGetAccrueHoursByLeaveType(@leaveTypeId);

	--DECLARE @value decimal(25, 15) = @dailyAccrueRate * @workedHours;

	DECLARE @change decimal(25,15) = (-@debit) + @credit

	DECLARE @caType int;
	SELECT @caType = ID FROM LeaveTransactionTypes WHERE code = 'CA';
	DECLARE @count int= (SELECT COUNT(*) FROM LeaveAccrualTransactions lat WHERE lat.EmployeeID= @empId and lat.LeaveTypeID= @leaveTypeId)
	DECLARE @currentBalance decimal(25,15)
	SET @currentBalance =(SELECT TOP 1 Balance from LeaveAccrualTransactions lat where lat.EmployeeID=@empId and lat.LeaveTypeID= @leaveTypeId and lat.DateFrom< @date order by lat.DateFrom desc, lat.ID desc)
	IF (@count>0) BEGIN
		INSERT INTO LeaveAccrualTransactions(EmployeeID, LeaveTypeID, DateFrom, DateTo, TransactionTypeID, Balance, Taken, Adjustment,
		Comment, Mode, LeaveRequestID, LeaveAdjustmentHeaderID)
		VALUES(@empId, @leaveTypeId, @date, @date, @caType, @currentBalance+@change, NULL, @change, '', '', NULL, @headerId)
	END ELSE BEGIN
		INSERT INTO LeaveAccrualTransactions(EmployeeID, LeaveTypeID, DateFrom, DateTo, TransactionTypeID, Balance, Taken, Adjustment,
		Comment, Mode, LeaveRequestID, LeaveAdjustmentHeaderID)
		VALUES(@empId, @leaveTypeId, @date, @date, @caType, @change, NULL, @change, '', '', NULL, @headerId)
	END
	
	DECLARE @newestID int = (select max(id) from LeaveAccrualTransactions);
	
	--UPDATE LeaveAccrualTransactions
	--set Balance= Balance+@change
	--where EmployeeID= @empId and LeaveTypeID= @leaveTypeId and DateFrom=@date and id != @newestID
	UPDATE LeaveAccrualTransactions 
	set Balance= Balance+@change
	where EmployeeID= @empId and LeaveTypeID= @leaveTypeId and DateFrom>=@date and id != @newestID
	--EXEC uspRegenAccrueDataByType @adjustDate, @empId, @leaveTypeId;
END

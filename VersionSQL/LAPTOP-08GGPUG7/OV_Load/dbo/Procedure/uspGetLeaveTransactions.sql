/****** Object:  Procedure [dbo].[uspGetLeaveTransactions]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetLeaveTransactions](@empId int, @leaveTypeId int, @page int)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @classify int = 0;
	DECLARE @otherClassify int = 5;
	SELECT @classify = ISNULL(LeaveClassify, 0) FROM LeaveType WHERE id = @leaveTypeId
	DECLARE @takenId int = 0;
	SELECT @takenId = ID FROM LeaveTransactionTypes WHERE Code = 'T';
	DECLARE @adjustmentId int = 0;
	SELECT @adjustmentId = ID FROM LeaveTransactionTypes WHERE CODE = 'CA';
	SELECT
		t.*, lt.[Description] as LeaveType, ltt.[Description] as LeaveTransactionType,
		t.Taken  as LeaveDays, -- day logic was removed to show in hours on all 3
		case when (ltt.id = @takenId or ltt.id = @adjustmentId) and exists (select _a.id from LeaveAccrualTransactions _a where _a.TimesheetID is not null AND _a.EmployeeID = @empId AND _a.DateFrom <= t.DateFrom and _a.DateTo >= t.DateFrom)  then 
		0
		else
		t.Balance end as BalanceDays,
		t.Adjustment as AdjustmentDays,
		lh.Reason as reason
	FROM
		LeaveAccrualTransactions t
	INNER JOIN
		LeaveTransactionTypes ltt
	ON
		t.TransactionTypeID = ltt.id
	INNER JOIN
		LeaveType lt
	ON
		lt.ID = t.LeaveTypeID
	left outer join LeaveAdjustmentHeader lh on t.LeaveAdjustmentHeaderID=lh.ID
	WHERE
		t.EmployeeID = @empId AND lt.LeaveClassify = @classify AND
		(lt.LeaveClassify <> @otherClassify OR lt.ID = @leaveTypeId)
		AND t.DateFrom <= GETDATE()
	ORDER BY
		t.DateTo DESC,  ltt.SortOrder ASC
	OFFSET (@page * 100) ROWS
	FETCH NEXT 100 ROWS ONLY
    
END

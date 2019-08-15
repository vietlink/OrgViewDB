/****** Object:  Procedure [dbo].[uspRegenAccrueDataByTimesheet]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspRegenAccrueDataByTimesheet](@dateStart datetime, @empId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @headerId int;

	DECLARE headerCursor CURSOR  
    FOR 
	SELECT
		h.ID
	FROM
		TimesheetHeader h
	INNER JOIN
		PayrollCycle c
	ON
		c.ID = h.PayrollCycleID
	INNER JOIN
		TimesheetStatus ts
	ON
		ts.ID = h.TimesheetStatusID
	WHERE
		c.FromDate >= @dateStart AND h.EmployeeID = @empId AND ts.Code = 'A'
	ORDER BY
		c.FromDate ASC

	OPEN headerCursor;
	FETCH NEXT FROM headerCursor INTO @headerId;

	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		print @headerId;
		EXEC dbo.uspGenerateAccrueDataByTimesheet @headerId, 1
		EXEC dbo.uspCreateTOILFromTimesheet @headerId
		FETCH NEXT FROM headerCursor INTO @headerId;
	END

	CLOSE headerCursor;  
	DEALLOCATE headerCursor;  

	UPDATE
		LeaveAccrualTransactions
	SET
		Balance = dbo.fnGetTotalAccrualCount2(DateFrom, EmployeeID, LeaveTypeID, 0)
	WHERE
		TimesheetID IS NULL AND EmployeeID = @empId AND DateFrom >= @dateStart
END

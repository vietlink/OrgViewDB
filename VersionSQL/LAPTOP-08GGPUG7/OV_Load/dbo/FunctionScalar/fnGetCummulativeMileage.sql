/****** Object:  Function [dbo].[fnGetCummulativeMileage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetCummulativeMileage] 
(
	-- Add the parameters for the function here
	@empID int, @expenseDate datetime, @startDate datetime, @toDate datetime
)
RETURNS decimal(7,2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result decimal(7,2)

	-- Add the T-SQL statements to compute the return value here
	
	SELECT @Result = isnull(sum(ecd.TotalMileage),0)
	FROM ExpenseClaimHeader ech 
	INNER JOIN ExpenseClaimDetail ecd ON ech.id= ecd.ExpenseClaimHeaderID
	INNER JOIN ExpenseStatus es ON ecd.ExpenseStatusID= es.ID
	WHERE ((ecd.ExpenseDate>=@startDate and ecd.ExpenseDate<=@expenseDate and @expenseDate<=@toDate) or (ecd.ExpenseDate= @expenseDate and @expenseDate>@toDate))
	and ech.EmployeeID= @empID
	and ech.ClaimType=2
	and es.Code='A'
	-- Return the result of the function
	RETURN @Result

END

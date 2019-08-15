/****** Object:  Function [dbo].[fnGetMileageAbove]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetMileageAbove]
(
	-- Add the parameters for the function here
	@empID int, @expenseDate datetime, @startTaxableDate datetime, @endTaxableDate datetime, @detailID int
)
RETURNS decimal(7,2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result decimal(7,2)
	declare @amount decimal(7,2) = (SELECT TotalMileage FROM ExpenseClaimDetail where id= @detailID)
	DECLARE @taxLimit int = (SELECT TaxFreeLimit FROM ExpenseClaimSettings)
	
	-- Add the T-SQL statements to compute the return value here
	DECLARE @cummulateMileage decimal(7,2)
	SELECT @cummulateMileage = isnull(sum(ecd.TotalMileage),0)
	FROM ExpenseClaimHeader ech 
	INNER JOIN ExpenseClaimDetail ecd ON ech.id= ecd.ExpenseClaimHeaderID
	INNER JOIN ExpenseStatus es ON ecd.ExpenseStatusID= es.ID
	WHERE ((ecd.ExpenseDate>=@startTaxableDate and @expenseDate<@endTaxableDate) 
	or (ecd.ExpenseDate>= DATEADD(day,1, @endTaxableDate) and @expenseDate>@endTaxableDate))
	and ech.EmployeeID= @empID
	and ecd.ExpenseDate<=@expenseDate 
	and ech.ClaimType=2
	and es.Code='A'
	and ecd.PayCycleID is null
	-- Return the result of the function
	SET @Result= @cummulateMileage- @taxLimit
	RETURN 
	CASE WHEN @Result <0 THEN 0
	WHEN @Result >@amount THEN @amount
	ELSE @Result 
	end
END
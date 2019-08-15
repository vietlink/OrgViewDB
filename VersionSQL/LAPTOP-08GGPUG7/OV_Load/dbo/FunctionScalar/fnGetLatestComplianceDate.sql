/****** Object:  Function [dbo].[fnGetLatestComplianceDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Ngo Linh
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION fnGetLatestComplianceDate 
(
	-- Add the parameters for the function here
	@empID int, @complianceListID int)
RETURNS datetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result datetime

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = MAX(ecl.DateFrom)
	FROM EmployeeCompetencyList ecl
	WHERE ecl.Employeeid= @empID AND ecl.CompetencyListId= @complianceListID
	

	-- Return the result of the function
	RETURN @Result

END

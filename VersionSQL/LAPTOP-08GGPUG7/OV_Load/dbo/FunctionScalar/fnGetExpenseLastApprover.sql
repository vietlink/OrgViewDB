/****** Object:  Function [dbo].[fnGetExpenseLastApprover]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
create FUNCTION [dbo].[fnGetExpenseLastApprover] 
(
	-- Add the parameters for the function here
	@headerID int
)
RETURNS varchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(max)

	-- Add the T-SQL statements to compute the return value here
	SET @Result= (SELECT TOP 1 (u.displayname) 
	FROM ExpenseStatusHistory esh 
	LEFT OUTER JOIN [User] u ON u.id= esh.ApprovedByID
	inner JOIN ExpenseStatus es ON esh.ExpenseStatusID= es.ID AND es.Code='A'
	WHERE 
	esh.ExpenseHeaderID=@headerID
	ORDER BY esh.date)


	-- Return the result of the function
	RETURN @Result

END


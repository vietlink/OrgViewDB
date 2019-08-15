/****** Object:  Function [dbo].[fnGetExpenseLastSubmitterEmail]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
create FUNCTION [dbo].[fnGetExpenseLastSubmitterEmail] 
(
	-- Add the parameters for the function here
	@headerID int
)
RETURNS varchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(max);
	DECLARE @userID int
	declare @userType varchar(50)
	-- Add the T-SQL statements to compute the return value here
	SET @userID= (SELECT TOP 1 (esh.SubmittedByID) 
	FROM ExpenseStatusHistory esh 	
	inner JOIN ExpenseStatus es ON esh.ExpenseStatusID= es.ID AND es.Code='S'	
	WHERE 
	esh.ExpenseHeaderID=@headerID
	ORDER BY esh.date desc)
	set @userType= (SELECT u.type FROM [User] u WHERE u.id= @userID)
	IF (@userType='System User' OR @userType='BuiltIn') BEGIN
		SET @Result= (SELECT u.WorkEmail FROM [User] u WHERE u.id= @userID)
	END
	ELSE BEGIN
		SET @Result= (SELECT ec.workemail FROM [User] u 
		INNER JOIN Employee e ON u.accountname= e.accountname
		INNER JOIN EmployeeContact ec ON e.id= ec.employeeid
		WHERE u.id= @userID)
	END

	-- Return the result of the function
	RETURN @Result

END


/****** Object:  Procedure [dbo].[uspGetWorkEmailFromEmployeeID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetWorkEmailFromEmployeeID](@empId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT WorkEmail FROM EmployeeContact WHERE Employeeid = @empId
END


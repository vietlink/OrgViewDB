/****** Object:  Function [dbo].[fnGetTopWorkProfileID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetTopWorkProfileID](@empId int)
RETURNS int
AS
BEGIN
	DECLARE @retId int;
	SELECT @retId = id FROM EmployeeWorkHoursHeader WHERE EmployeeID = @empId ORDER BY DateFrom DESC

	RETURN @retId;

END


/****** Object:  Procedure [dbo].[uspValidateNewTimesheetHeaderWithDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspValidateNewTimesheetHeaderWithDate](@empId int, @dateFrom datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		(SELECT TOP 1 DateFrom FROM EmployeeWorkHoursHeader WHERE DateFrom >= @dateFrom AND EmployeeID = @empId ORDER BY DateFrom ASC) as ValidateFuture
	--	(SELECT TOP 1 DateFrom FROM EmployeeWorkHoursHeader WHERE DateFrom <= @dateFrom AND EmployeeID = @empId ORDER BY DateTo DESC) as ValidatePast
END


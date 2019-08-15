/****** Object:  Procedure [dbo].[uspGetProfileEarlierThan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetProfileEarlierThan](@profileId int, @newDateTime datetime, @empId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @dateFrom datetime;
	SELECT @dateFrom = DateFrom FROM EmployeeWorkHoursHeader WHERE ID = @profileId;
	
	SELECT * FROM EmployeeWorkHoursHeader WHERE EmployeeID = @empId AND DateFrom <= @dateFrom AND DateFrom >= @newDateTime AND ID <> @profileId
	
END


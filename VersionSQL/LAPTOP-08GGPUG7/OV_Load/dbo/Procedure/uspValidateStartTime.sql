/****** Object:  Procedure [dbo].[uspValidateStartTime]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspValidateStartTime](@empId int, @dateFrom datetime, @time varchar(5), @dayCode varchar(20))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @headerId int = dbo.fnGetWorkHourHeaderIDByDay(@empId, @dateFrom);
	DECLARE @scanDate DateTime;
	select @scanDate = convert(datetime, '2000-01-01 ' + @time, 101);

	IF NOT EXISTS (SELECT ID FROM EmployeeWorkHours
		WHERE EmployeeID = @empID AND [Enabled] = 1 
		AND EmployeeWorkHoursHeaderID = @headerId 
		and DayCode= @dayCode
		AND StartDateTime <= @scanDate 
		AND ((EndDateTime >= @scanDate AND StartDateTime<= EndDateTime) OR (StartDateTime> EndDateTime AND DATEADD(day, 1, EndDateTime)>=@scanDate))) BEGIN
		SELECT 0 as isValid
	END ELSE
		SELECT 1 as isValid
END


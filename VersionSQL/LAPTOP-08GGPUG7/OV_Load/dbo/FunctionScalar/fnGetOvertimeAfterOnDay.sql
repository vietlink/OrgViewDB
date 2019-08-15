/****** Object:  Function [dbo].[fnGetOvertimeAfterOnDay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetOvertimeAfterOnDay](@empId int, @date datetime)
RETURNS decimal(10,5)
AS
BEGIN
	DECLARE @overtimeAfter decimal(10,5);
    DECLARE @currentHeader int = dbo.fnGetWorkHourHeaderIDByDay(@empId, @date);
	SELECT @overtimeAfter = ISNULL(OvertimeStartsAfter, 0) FROM dbo.fnGetWorkDayData(@empId, @date, @currentHeader);
	RETURN ISNULL(@overtimeAfter, 0);

END


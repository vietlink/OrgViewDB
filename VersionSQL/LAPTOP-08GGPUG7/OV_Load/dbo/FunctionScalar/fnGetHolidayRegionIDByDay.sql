/****** Object:  Function [dbo].[fnGetHolidayRegionIDByDay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetHolidayRegionIDByDay](@empId int, @date datetime)
RETURNS int
AS
BEGIN
    DECLARE @id int;
	DECLARE @regionID int = 0;

	SELECT @id = ISNULL(id, 0), @regionID = HolidayRegionID FROM EmployeeWorkHoursHeader WHERE EmployeeID = @empId AND ((@date >= DateFrom AND @date <= cast(convert(char(8), DateTo, 112) + ' 23:59:59.99' as datetime))
	OR (@date >= DateFrom AND DateTo IS NULL))
	ORDER BY DateFrom DESC
	--this needs to return back the first found date if no current ones are found
	IF ISNULL(@id, 0) = 0 BEGIN
		SELECT @id = ISNULL(id, 0), @regionID = HolidayRegionID FROM EmployeeWorkHoursHeader WHERE EmployeeID = @empId AND ((@date >= DATEADD(day, -31, DateFrom) AND @date <= cast(convert(char(8), DateTo, 112) + ' 23:59:59.99' as datetime))
			OR (@date >= DATEADD(day, -31, DateFrom) AND DateTo IS NULL))
	END
	RETURN ISNULL(@regionID, 0)
END


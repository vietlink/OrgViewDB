/****** Object:  Function [dbo].[fnGetLeaveHoursOnDayByHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetLeaveHoursOnDayByHeader](@headerId int, @date datetime)
RETURNS decimal(18,2)
AS
BEGIN
	DECLARE @hours decimal(18,2)
	SELECT TOP 1 @hours = Duration FROM LeaveRequestDetail WHERE LeaveRequestID = @headerId AND LeaveDateFrom = @date;
	RETURN ISNULL(@hours, 0);
END


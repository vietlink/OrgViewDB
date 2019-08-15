/****** Object:  Procedure [dbo].[uspCheckShiftLoadingExist]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspCheckShiftLoadingExist 
	-- Add the parameters for the stored procedure here
	@shiftLoadingID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COUNT(*) as _count FROM
	EmployeeWorkHoursHeader ewh, TimesheetHeader th
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
	WHERE ewh.EmployeeID=th.EmployeeID	
	AND ewh.TimeShiftLoadingHeaderID= @shiftLoadingID
	AND ts.Code!='P' AND ts.Code!='R'
	
END

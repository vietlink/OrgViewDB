/****** Object:  Procedure [dbo].[uspCheckUsedLoadingRate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckUsedLoadingRate] 
	-- Add the parameters for the stored procedure here
	@rateID int, @ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SET @ReturnValue=(SELECT  COUNT(*) FROM TimesheetRateAdjustmentItem WHERE RateID= @rateID)
	+(SELECT COUNT(*) FROM EmployeeWorkHoursHeader ewh INNER JOIN TimeShiftLoadingHeader tsh ON ewh.TimeShiftLoadingHeaderID= tsh.ID
	INNER JOIN TimeShiftLoadingRates tsr ON tsh.id= tsr.TimeShiftLoadingHeaderID INNER JOIN TimesheetHeader th ON ewh.EmployeeID= th.EmployeeID
	 WHERE (tsr.MondayID=@rateID OR tsr.TuesdayID= @rateID OR tsr.WednesdayID= @rateID 
	 OR tsr.ThursdayID= @rateID OR tsr.FridayID= @rateID OR tsr.SaturdayID= @rateID OR tsr.SundayID= @rateID OR tsr.PublicHolidayID= @rateID))
	RETURN @ReturnValue
END

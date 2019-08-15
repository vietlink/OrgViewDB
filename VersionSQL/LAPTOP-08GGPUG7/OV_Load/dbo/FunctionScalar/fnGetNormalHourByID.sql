/****** Object:  Function [dbo].[fnGetNormalHourByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION fnGetNormalHourByID 
(
	-- Add the parameters for the function here
	@id int
)
RETURNS decimal(10,5)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result decimal(10,5)

	-- Add the T-SQL statements to compute the return value here
	DECLARE @normalID int= (SELECT id from LoadingRate WHERE IsNormalRate=1)
	DECLARE @adjustmentVal decimal(10,5)=isnull(( SELECT isnull(trai.balance,0) FROM TimesheetRateAdjustment tra 
	LEFT OUTER JOIN TimesheetRateAdjustmentItem trai on tra.ID= trai.TimesheetRateAdjustmentID
	WHERE trai.RateID= @normalID and tra.TimesheetHeaderID= @id and tra.IsFinalisedHours=1),0)
	DECLARE @normalVal decimal(10,5)= (SELECT isnull(tra.NormalRate,0) FROM TimesheetRateAdjustment tra 
	WHERE tra.TimesheetHeaderID=@id and tra.IsFinalisedHours=1)

	-- Return the result of the function
	RETURN @normalVal+@adjustmentVal;

END

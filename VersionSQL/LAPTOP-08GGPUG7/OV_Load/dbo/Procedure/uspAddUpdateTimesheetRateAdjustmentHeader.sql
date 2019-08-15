/****** Object:  Procedure [dbo].[uspAddUpdateTimesheetRateAdjustmentHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateTimesheetRateAdjustmentHeader](@id int, @timesheetHeaderID int, @comment varchar(255), @normalRate decimal(10,5), @toilRate decimal(10,5), @isFinal bit, @displayName varchar(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @toilRate > 0 BEGIN
		UPDATE TimesheetHeader SET RequiresAdditionalApproval = 1 WHERE ID = @timesheetHeaderID;
	END
	
	IF @id > 0 BEGIN
		UPDATE 
			TimesheetRateAdjustment
		SET
			comment = @comment,
			normalrate = @normalRate,
			toilrate = @toilRate
		WHERE
			id = @id
		RETURN @id;
	END
	ELSE BEGIN
		INSERT INTO TimesheetRateAdjustment(TimesheetHeaderID, Comment, NormalRate, ToilRate, IsFinalisedHours, DisplayName)
			VALUES(@timesheetHeaderID, @comment, @normalRate, @toilRate, @isFinal, @displayName)
		RETURN @@IDENTITY
	END
END

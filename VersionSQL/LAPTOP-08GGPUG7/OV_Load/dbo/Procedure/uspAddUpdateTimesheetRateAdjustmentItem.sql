/****** Object:  Procedure [dbo].[uspAddUpdateTimesheetRateAdjustmentItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateTimesheetRateAdjustmentItem](@timesheetRateAdjustmentID int, @rate decimal(10,5), @balance decimal(10,5), @rateId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @rateID int = 0;
	--SELECT @rateID = ID FROM LoadingRate WHERE Value = @rate;
	DECLARE @timesheetHeaderId int;
	SELECT @timesheetHeaderId = TimesheetHeaderID FROM TimesheetRateAdjustment WHERE ID = @timesheetRateAdjustmentID;
	DECLARE @payrollCycleId int;
	DECLARE @empId int;
	SELECT @payrollCycleId = PayrollCycleID, @empId = EmployeeID FROM TimesheetHeader WHERE ID = @timesheetHeaderId;
	DECLARE @dateFrom datetime;
	SELECT @dateFrom = FromDate FROM PayrollCycle WHERE ID = @payrollCycleId

	DECLARE @workHeaderId int = dbo.fnGetWorkHourHeaderIDByDay(@empId, @dateFrom);

	DECLARE @overtimeRateId int;
	DECLARE @shiftLoadingHeaderId int;

	SELECT @overtimeRateId = NormalOvertimeRate, @shiftLoadingHeaderId = TimeShiftLoadingHeaderID FROM EmployeeWorkHoursHeader WHERE ID = @workHeaderId;
	CREATE TABLE #rates
	(
		rateId int
	);

	INSERT INTO #rates SELECT MondayID FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId
	INSERT INTO #rates SELECT TuesdayID FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId
	INSERT INTO #rates SELECT WednesdayID FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId
	INSERT INTO #rates SELECT ThursdayID FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId
	INSERT INTO #rates SELECT FridayID FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId
	INSERT INTO #rates SELECT SaturdayID FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId
	INSERT INTO #rates SELECT SundayID FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId
	INSERT INTO #rates SELECT @overtimeRateId FROM TimeShiftLoadingRates WHERE TimeShiftLoadingHeaderID = @shiftLoadingHeaderId

	--SELECT @rateID = ID FROM LoadingRate WHERE ID IN (select rateId from #rates) and [Value] = @rate

	IF ISNULL(@rateID, 0) = 0
		SELECT @rateID = ID FROM LoadingRate WHERE Value = @rate;

	DROP TABLE #rates

	DECLARE @id int;
	SELECT @id = ID FROM TimesheetRateAdjustmentItem WHERE TimesheetRateAdjustmentID = @timesheetRateAdjustmentID AND RateID = @rateID
	print @id
    IF @id > 0 BEGIN
	print 'a'
		UPDATE
			TimesheetRateAdjustmentItem
		SET
			Balance = @balance
		WHERE
			id = @id;
	END
	ELSE BEGIN
	print 'b'
		INSERT INTO
			TimesheetRateAdjustmentItem(TimesheetRateAdjustmentID, RateID, Balance)
				VALUES(@timesheetRateAdjustmentID, @rateID, @balance)
	END

	DECLARE @tsHeaderId int = 0;
	SELECT @tsHeaderId = TimeSheetHeaderID FROM TimesheetRateAdjustment WHERE ID = @timesheetRateAdjustmentID

	DECLARE @toilCount decimal(10,5)
	SELECT @toilCount = ToilHours FROM TimesheetHeader WHERE ID = @tsHeaderId

	IF dbo.fnGetTimesheetAdjustmentCount(@tsHeaderId) > 0 OR @toilCount > 0 BEGIN
		UPDATE TimesheetHeader SET RequiresAdditionalApproval = 1 WHERE ID = @tsHeaderId
	END
END

/****** Object:  Procedure [dbo].[uspUpdateTimeWorkProfileTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateTimeWorkProfileTemplate](@id int, @shortDescription varchar(100), @description varchar(255), @code varchar(20), @payRollCycle int, 
	@enableTimesheet bit, @enableProjectTimesheet bit, @enableSwipeCard bit, @timesheetTimeMode int, @projectTimeMode int, @defaultRecordingMethod int,
	@defaultProjectId int, @defaultTaskId int, @standardWorkHours int, @timeWorkHoursHeaderId int, @timeShiftLoadingHeaderId int, @allowOvertime bit,
	@normalOvertimeRate int, @overtimeStartsAfter decimal(10,5), @defaultOvertimeTo int, @applyOvertimeOption int, @startBuffer decimal(10,5),
	@finishBuffer decimal(10,5), @allowAutoApproval bit, @maxToilBalance decimal(10, 5), @noApprovalForLeave bit, @noApprovalForTimesheet bit, @noApprovalForExpense bit, @paycostcentreid int, @expensecostcentreid int,
	@moduleTimesheet bit, @moduleLeave bit, @moduleExpense bit, @extraHoursPayType int, @processPayroll bit, @deductBreaks bit, @deductAfter decimal(10,5), @hasPublicHoliday bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @id > 0 BEGIN
		UPDATE
			TimeWorkProfileTemplate
		SET
			ShortDescription = @shortDescription,
			[Description] = @description,
			Code = @code, 
			PayRollCycle = @payRollCycle,
			EnableTimesheet = @enableTimesheet,
			EnableProjectTimesheet = @enableProjectTimesheet,
			EnableSwipeCard = @enableSwipeCard,
			TimesheetTimeMode = @timesheetTimeMode,
			ProjectTimeMode = @projectTimeMode,
			DefaultRecordingMethod = @defaultRecordingMethod,
			DefaultProjectID = @defaultProjectId,
			DefaultTaskID = @defaultTaskId,
			StandardWorkHours = @standardWorkHours,
			TimeWorkHoursHeaderID = @timeWorkHoursHeaderId,
			TimeShiftLoadingHeaderID = @timeShiftLoadingHeaderId,
			AllowOvertime = @allowOvertime,
			NormalOvertimeRate = @normalOvertimeRate,
			OvertimeSTartsAfter = @overtimeStartsAfter,
			DefaultOvertimeTo = @defaultOvertimeTo,
			ApplyOvertimeOption = @applyOvertimeOption,
			StartBuffer = @startBuffer,
			FinishBuffer = @finishBuffer,
			AllowAutoApproval = @allowAutoApproval,
			MaxToilBalance = @maxToilBalance,
			NoApprovalForLeave = @noApprovalForLeave,
			NoApprovalForTimesheet = @noApprovalForTimesheet,
			NoApprovalForExpense = @noApprovalForExpense,
			PayCostCentreId = @paycostcentreid,
			ExpenseCostCentreId = @expensecostcentreid,
			ModuleTimesheet = @moduleTimesheet,
			ModuleLeave = @moduleLeave,
			ModuleExpense = @moduleExpense,
			ExtraHoursPayType = @extraHoursPayType,
			ProcessPayroll = @processPayroll,
			DeductBreaks = @deductBreaks,
			DeductAfter = @deductAfter,
			HasPublicHoliday= @hasPublicHoliday
		WHERE
			ID = @id
	END ELSE BEGIN
		INSERT INTO
			TimeWorkProfileTemplate(ShortDescription,[Description],Code,PayRollCycle,EnableTimesheet,EnableProjectTimesheet,EnableSwipeCard,
			TimesheetTimeMode,ProjectTimeMode,DefaultRecordingMethod,DefaultProjectID,DefaultTaskID,StandardWorkHours,
			TimeWorkHoursHeaderID,TimeShiftLoadingHeaderID,AllowOvertime,NormalOvertimeRate,OvertimeStartsAfter,
			DefaultOvertimeTo,ApplyOvertimeOption,StartBuffer,FinishBuffer,AllowAutoApproval,MaxToilBalance, IsDeleted, NoApprovalForLeave, NoApprovalForTimesheet, NoApprovalForExpense, PayCostCentreId, ExpenseCostCentreId,
			ModuleTimesheet, ModuleLeave, ModuleExpense, ExtraHoursPayType, ProcessPayroll, DeductBreaks, DeductAfter, HasPublicHoliday)
		VALUES(@shortDescription,@description,@code, @payRollCycle,@enableTimesheet,@enableProjectTimesheet,@enableSwipeCard,@timesheetTimeMode,@projectTimeMode,@defaultRecordingMethod,
				@defaultProjectId,@defaultTaskId,@standardWorkHours,@timeWorkHoursHeaderId,@timeShiftLoadingHeaderId,@allowOvertime,@normalOvertimeRate,@overtimeStartsAfter,@defaultOvertimeTo,
				@applyOvertimeOption,@startBuffer,@finishBuffer,@allowAutoApproval,@maxToilBalance, 0, @NoApprovalForLeave, @NoApprovalForTimesheet, @NoApprovalForExpense, @paycostcentreid, @expensecostcentreid,
				@moduleTimesheet, @moduleLeave, @moduleExpense, @extraHoursPayType, @processPayroll, @deductBreaks, @deductAfter, @hasPublicHoliday)

	END

END

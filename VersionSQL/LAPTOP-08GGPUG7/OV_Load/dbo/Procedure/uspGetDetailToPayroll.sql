/****** Object:  Procedure [dbo].[uspGetDetailToPayroll]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetDetailToPayroll] 
	-- Add the parameters for the stored procedure here
	@paycycleID int, @leaveTypeList varchar(max), @timesheetIncluded int, @leaveIncluded int, @claimIncluded int, @sortBy varchar(max), @chkPrevious int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @payGroupID int = (SELECT isnull(p.PayrollCycleGroupID,0) FROM PayrollCycle p WHERE p.id= @paycycleID)
	DECLARE @fromDate DATETIME = (SELECT p.FromDate FROM PayrollCycle p WHERE p.id= @paycycleID)
	DECLARE @toDate DATETIME = (SELECT p.ToDate FROM PayrollCycle p WHERE p.id= @paycycleID)
	DECLARE @status varchar(1)= (SELECT ps.Code FROM PayrollCycle p INNER JOIN PayrollStatus ps ON p.PayrollStatusID= ps.ID WHERE p.ID= @paycycleID)
	DECLARE @expenseCode varchar(max)= (SELECT ec.Code FROM ExpenseClaimSettings t INNER JOIN ExpenseCode ec ON t.DefaultExpenseCodeID= ec.ID)
	DECLARE @expenseCodeDesc varchar(max)= (SELECT ec.Description FROM ExpenseClaimSettings t INNER JOIN ExpenseCode ec ON t.DefaultExpenseCodeID= ec.ID)
	DECLARE @nontaxexpenseCode varchar(max)= (SELECT ec.Code FROM ExpenseClaimSettings t INNER JOIN ExpenseCode ec ON t.MileageNonTaxExpenseCodeID= ec.ID)
	DECLARE @nontaxexpenseCodeDesc varchar(max)= (SELECT ec.Description FROM ExpenseClaimSettings t INNER JOIN ExpenseCode ec ON t.MileageNonTaxExpenseCodeID= ec.ID)
	declare @leaveTable Table (leave varchar(max));	
	DECLARE @taxFreeLimit int= (SELECT TaxFreeLimit FROM ExpenseClaimSettings )
	DECLARE @taxableYear int= YEAR(@toDate)
	DECLARE @taxableDay int = (SELECT StartDay FROM ExpenseClaimSettings)
	DECLARE @taxableMonth int= (SELECT StartMonth FROM ExpenseClaimSettings)
	DECLARE @tempDate Datetime= DATEFROMPARTS(@taxableYear, @taxableMonth, @taxableDay)
	IF (@tempDate>@toDate) BEGIN
		SET @taxableYear= @taxableYear-1
	END
	DECLARE @startTaxableDate datetime= DATEFROMPARTS(@taxableYear, @taxableMonth, @taxableDay)
	DECLARE @endTaxableDate datetime= DATEADD(day,-1,DATEFROMPARTS(@taxableYear+1, @taxableMonth, @taxableDay));
	DECLARE @yearExpenseCode varchar(max)= (SELECT ec.Code FROM ExpenseClaimSettings t INNER JOIN ExpenseCode ec ON t.YearLimitExpenseCodeID= ec.ID)
	DECLARE @yearExpenseCodeDesc varchar(max)= (SELECT ec.Description FROM ExpenseClaimSettings t INNER JOIN ExpenseCode ec ON t.YearLimitExpenseCodeID= ec.ID)
	DECLARE @paidRate decimal(5,2)= (SELECT MileageRatePaid FROM ExpenseClaimSettings)
	IF CHARINDEX(',', @leaveTypeList, 0) > 0 BEGIN
		INSERT INTO @leaveTable -- split the text by , and store in temp table
		SELECT splitdata FROM fnSplitString(@leaveTypeList, ',');	
		END
    ELSE IF LEN(@leaveTypeList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @leaveTable(leave) VALUES(@leaveTypeList);	
	end
    -- Insert statements for procedure here

SELECT * FROM (
--normal leave
	SELECT isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,
		lrd.ID as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		lt.Code as PayCode,
		lt.ReportDescription as PayCodeDescription,
		--CONCAT(lr.DateFrom,' - ', lr.DateTo) as _date,	
		lrd.LeaveDateFrom as _date,
		lrd.LeaveDateFrom as _date1,
		lrd.LeaveDateFrom as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		lrd.Duration as Amount,
		lrd.Duration as totalAmount,
		lrd.payrollcycleid as paycycle,
		--lrd.ID as LeaveDetailID,
		2 as isPayout,
		'leave' as type,
		0 as CompRate,
		0 as GovRate,
		isnull(c.Code,'') as costCentre,
		lr.ID as requestID,
		lt.SystemCode as systemCode
	FROM Employee e
	
	LEFT OUTER JOIN EmployeePosition ep ON e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	INNER JOIN LeaveRequest lr on e.id= lr.EmployeeID
	INNER JOIN LeaveRequestDetail lrd on lr.ID= lrd.LeaveRequestID
	INNER JOIN LeaveType lt on lr.LeaveTypeID= lt.ID	
	INNER JOIN LeaveStatus ls on lr.LeaveStatusID=ls.ID
	LEFT OUTER JOIN TimesheetHeader th ON e.id= th.EmployeeID 
	LEFT OUTER JOIN EmployeeWorkHoursHeader ewh ON ewh.EmployeeID= e.id and dbo.fnGetWorkHourHeaderIDByDay(e.id, lrd.LeaveDateFrom)=ewh.ID and ewh.ProcessPayroll=1	
	inner join PayrollCycleGroups pg on ewh.PayRollCycle= pg.ID and pg.id= @payGroupID
	left outer join CostCentres c on ewh.PayCostCentreID = c.ID
	WHERE ls.Code='A'
	AND @leaveIncluded=1
	--and e.IsDeleted=0 
	and e.IsPlaceholder=0
	--AND (@timesheetIncluded=1 AND (th.PayrollCycleID=@paycycleID) OR @timesheetIncluded=0)
	and dbo.fnGetHoursInDay(e.id, lrd.LeaveDateFrom) is not null
	
	AND ((SELECT COUNT(*) FROM @leaveTable) = 0 OR lt.ReportDescription IN (SELECT * FROM @leaveTable))		
	AND (((@status='O') AND ((lrd.LeaveDateFrom<=@toDate) AND lrd.PayrollCycleID=0)) OR ((@status='C') AND lrd.PayrollCycleID= @paycycleID))
--leave adjustment
UNION
	SELECT
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,
		lat.ID as detailID,
		e.displayname as Displayname,
		e.surname as Surname,
		lt.AccrualCode as PayCode,
		lt.ReportDescription as PayCodeDescription,
		--concat(lah.Date,' - ', lah.Date) as _date,
		lah.Date as _date,
		lah.Date as _date1,
		lah.Date as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		lat.Adjustment as Amount,
		lat.Adjustment as totalAmount,
		lat.payrollcycleID as paycycle,
		--0 as LeaveDetailID,
		lah.isPayout as isPayout,
		'leave' as type,
		0 as CompRate,
		0 as GovRate,
		isnull(c.Code,'') as costCentre,
		-1 as requestID,
		lt.SystemCode as systemCode	
	FROM Employee e 
	left outer join EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	left outer join LeaveAccrualTransactions lat on e.id= lat.EmployeeID
	inner join LeaveType lt on lat.LeaveTypeID= lt.ID
	left outer join LeaveAdjustmentHeader lah on lat.LeaveAdjustmentHeaderID= lah.ID
	LEFT OUTER JOIN TimesheetHeader th ON e.id= th.EmployeeID
	INNER JOIN EmployeeWorkHoursHeader ewh ON ewh.EmployeeID= e.id and dbo.fnGetWorkHourHeaderIDByDay(e.id, lah.Date)=ewh.ID and ewh.ProcessPayroll=1 
	inner join PayrollCycleGroups pg on ewh.PayRollCycle= pg.ID and pg.id= @payGroupID
	left outer join CostCentres c on ewh.PayCostCentreID = c.ID
	where lah.isPayout = 1 and @leaveIncluded=1
	--and e.IsDeleted=0 
	and e.IsPlaceholder=0
	AND ((SELECT COUNT(*) FROM @leaveTable) = 0 OR lt.ReportDescription IN (SELECT * FROM @leaveTable))		
	--AND (@timesheetIncluded=1 AND (th.PayrollCycleID=@paycycleID) OR @timesheetIncluded=0)
	AND (((@status='O') AND ((lat.DateFrom<=@toDate) AND lat.PayrollCycleID =0)) OR ((@status='C') AND lat.PayrollCycleID= @paycycleID))	
--public holiday
UNION
	select 
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		0 as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		lt.Code as PayCode,
		lt.ReportDescription as PayCodeDescription,
		h.Date as _date,
		h.Date as _date1,
		h.Date as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		iif(dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end)>0,dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end),0) as Amount,
		iif(dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end)>0,dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end),0) as totalAmount,
		0 as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'leave' as type,
		0 as CompRate,
		0 as GovRate,
		isnull(c.Code,'') as costCentre,
		0 as requestID,
		lt.SystemCode as systemCode			
	from Employee e
	LEFT OUTER JOIN TimesheetHeader th ON e.id= th.EmployeeID
	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
	LEFT OUTER JOIN TimesheetDay td ON td.TimesheetHeaderID= th.ID
	left outer JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1
	left outer join CostCentres c on ewh.PayCostCentreID = c.ID	
	inner join HolidayRegion hr on ewh.HolidayRegionID=hr.ID
	inner join Holiday h on h.HolidayRegionID= hr.ID, LeaveType lt 	
	
	where 				
		dbo.fnGetHoursInDay(e.id, h.Date) >0			
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and h.Date= td.Date		
		and
		 ewh.ModuleLeave=1
		and isnull(dbo.fnGetWorkHourHeaderIDByDay(e.id, h.Date),0) =ewh.ID
		
		and @leaveIncluded =1
		--AND ((@timesheetIncluded=1 AND th.PayrollCycleID=@paycycleID and ) OR @timesheetIncluded=0)
		and lt.SystemCode='P'
		and ewh.HasPublicHolidays = 1					
		and (
		(h.Date>=@fromDate and h.Date<=@toDate and (@chkPrevious=0 or @timesheetIncluded=0 
		or ((select count(*) from TimesheetHeader th1 		
		inner join TimesheetStatus ts1 on th1.TimesheetStatusID= ts1.ID 		
		where EmployeeID= e.id 		
		and ProcessedPayCycleID is null 
		and ts1.Code='A'
		and th1.PayrollCycleID=@paycycleID)=0)))
		--OR (@chkPrevious=1 and @timesheetIncluded=1 and @leaveIncluded=1 and h.Date>= pc.FromDate and h.Date<=pc.ToDate and th.EmployeeID= e.id and th.ProcessedPayCycleID is null and ts.Code='A' )	
		)
		and pc.PayrollCycleGroupID= @payGroupID
		AND ((SELECT COUNT(*) FROM @leaveTable) = 0 OR lt.ReportDescription IN (SELECT * FROM @leaveTable))
--past public holiday
UNION
	select 
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		0 as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		lt.Code as PayCode,
		lt.ReportDescription as PayCodeDescription,
		h.Date as _date,
		h.Date as _date1,
		h.Date as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		iif(dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end)>0,dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end),0) as Amount,
		iif(dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end)>0,dbo.fnGetHoursInDay(e.ID, h.Date)- (case when td.StartTime='' then 0 else isnull(td.Hours,0) end),0) as totalAmount,
		0 as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'leave' as type,
		0 as CompRate,
		0 as GovRate,
		isnull(c.Code,'') as costCentre,
		0 as requestID,
		lt.SystemCode as systemCode			
	from Employee e
	LEFT OUTER JOIN TimesheetHeader th ON e.id= th.EmployeeID
	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
	LEFT OUTER JOIN TimesheetDay td ON td.TimesheetHeaderID= th.ID
	left outer JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1 and ewh.ModuleLeave=1 and ewh.HasPublicHolidays = 1	
	left outer join CostCentres c on ewh.PayCostCentreID = c.ID	
	inner join HolidayRegion hr on ewh.HolidayRegionID=hr.ID
	inner join Holiday h on h.HolidayRegionID= hr.ID, LeaveType lt 
	
	where 	
		th.ProcessedPayCycleID is null and ts.Code='A' 			
		and (h.Date>= pc.FromDate and h.Date<=pc.ToDate)	
		and h.Date<=@toDate --prevent getting public holiday of future timesheet
		and pc.PayrollCycleGroupID= @payGroupID
		and @chkPrevious=1 and @timesheetIncluded=1 and @leaveIncluded=1
		and dbo.fnGetHoursInDay(e.id, h.Date) >0			
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and h.Date= td.Date		
		and isnull(dbo.fnGetWorkHourHeaderIDByDay(e.id, h.Date),0) =ewh.ID
		and lt.SystemCode='P'		 		
														
		AND ((SELECT COUNT(*) FROM @leaveTable) = 0 OR lt.ReportDescription IN (SELECT * FROM @leaveTable))
-- timesheet normal rate 
UNION
	select
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		th.ID as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		lr.Code as PayCode,
		lr.Description as PayCodeDescription,
		pc.FromDate as _date,
		pc.FromDate as _date1,
		pc.ToDate as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		(dbo.fnGetNormalHourByID(th.id)-isnull(tss.PaidLeaveHours,0)) as Amount,
		(dbo.fnGetNormalHourByID(th.id)-isnull(tss.PaidLeaveHours,0)) as totalAmount,
		0 as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'timesheet' as type,
		0 as CompRate,
		0 as GovRate,
		isnull(c.Code, '') as costCentre,
		th.ID as requestID,
		'' as systemCode	
	from Employee e
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1 
	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	INNER JOIN TimesheetHeader th ON th.EmployeeID= e.id
	LEFT OUTER JOIN CostCentres c On th.CostCentreID= c.ID
	LEFT OUTER JOIN TimesheetRateAdjustment tra ON th.ID= tra.TimesheetHeaderID and tra.IsFinalisedHours = 1
	LEFT OUTER JOIN TimesheetRateAdjustmentItem trai ON tra.ID= trai.TimesheetRateAdjustmentID
	LEFT OUTER JOIN TimesheetSummary tss ON th.ID= tss.TimesheetHeaderID AND tss.[Week] IS NULL
	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
	LEFT OUTER JOIN PayrollCycleGroups pg ON pc.PayrollCycleGroupID= pg.ID 
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID,LoadingRate lr 
	
	where 		
		@timesheetIncluded=1
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and tra.IsFinalisedHours=1
		and ((dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.FromDate)=ewh.ID and dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.ToDate)=ewh.ID) or (dbo.fnGetWorkHeaderInPeriod(e.id, pc.FromDate, pc.ToDate)=ewh.id))
		and (lr.IsNormalRate=1 )
		--and ((trai.RateID= lr.ID) )
		--and tra.NormalRate is not null
		and ts.Code='A'					
		and isnull(pg.ID, 0)=@payGroupID
		AND (((@status='O') AND (th.ProcessedPayCycleID is null and pc.ToDate<=@toDate ))
		OR ((@status='C') AND th.ProcessedPayCycleID = @paycycleID))	

-- timesheet TOIL
UNION
	select
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		th.ID as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		lt.AccrualCode as PayCode,
		lt.Description as PayCodeDescription,
		pc.FromDate as _date,
		pc.FromDate as _date1,
		pc.ToDate as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		isnull(tra.ToilRate,0) as Amount,
		isnull(tra.ToilRate,0) as totalAmount,
		0 as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'timesheet' as type,
		0 as CompRate,
		0 as GovRate,
		isnull(c.Code, '') as costCentre,
		th.ID as requestID,
		'' as systemCode		
	from Employee e
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1 
	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	INNER JOIN TimesheetHeader th ON th.EmployeeID= e.id
	LEFT OUTER JOIN CostCentres c On th.CostCentreID= c.ID
	LEFT OUTER JOIN TimesheetRateAdjustment tra ON th.ID= tra.TimesheetHeaderID and tra.IsFinalisedHours = 1
	LEFT OUTER JOIN TimesheetRateAdjustmentItem trai ON tra.ID= trai.TimesheetRateAdjustmentID
	
	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
	LEFT OUTER JOIN PayrollCycleGroups pg ON pc.PayrollCycleGroupID= pg.ID 
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID,LoadingRate lr, LeaveType lt 
	
	where 		
		@timesheetIncluded=1
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and (lr.IsNormalRate=1 )
		and tra.IsFinalisedHours=1
		and ((dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.FromDate)=ewh.ID and dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.ToDate)=ewh.ID) or (dbo.fnGetWorkHeaderInPeriod(e.id, pc.FromDate, pc.ToDate)=ewh.id))
		and lt.LeaveClassify=4 and lt.SystemCode='TOIL'
		--and tra.NormalRate is not null
		and ts.Code='A'					
		and isnull(pg.ID, 0)=@payGroupID
		AND (((@status='O') AND (th.ProcessedPayCycleID is null and pc.ToDate<=@toDate ))
		OR ((@status='C') AND th.ProcessedPayCycleID = @paycycleID))	
-- timesheet adjustment rate
--UNION
--	select
--		isnull(e.PayrollID,'') as payrollID,
--		e.id as EmployeeID,		
--		th.ID as detailID,
--		e.displayname as DisplayName,
--		e.surname as Surname,
--		lr.Code as PayCode,
--		lr.Description as PayCodeDescription,
--		pc.FromDate as _date,
--		pc.FromDate as _date1,
--		pc.ToDate as _todate,
--		@fromDate as FromDate,
--		@toDate as ToDate,
--		ABS(isnull(trai.Balance,0)- th.OvertimeHours) as Amount,
--		ABS(isnull(trai.Balance,0)- th.OvertimeHours) as totalAmount,
--		1 as paycycle,
--		--0 as LeaveDetailID,
--		2 as isPayout,
--		'timesheet' as type,
--		0 as CompRate,
--		0 as GovRate,
--		isnull(c.Code, '') as costCentre,
--		0 as requestID,
--		'' as systemCode		
--	from Employee e
--	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1
--	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
--	INNER JOIN TimesheetHeader th ON th.EmployeeID= e.id
--	INNER JOIN Timesheetsummary ths ON th.ID= ths.TimesheetHeaderID and ths.Week is null
--	LEFT OUTER JOIN LoadingRate lr1 ON ths.OvertimeRateID = lr1.ID
--	LEFT OUTER JOIN CostCentres c ON th.CostCentreID= c.ID
--	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
--	LEFT OUTER JOIN PayrollCycleGroups pg ON pc.PayrollCycleGroupID= pg.ID
--	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
--	INNER JOIN TimesheetRateAdjustment tra ON th.ID= tra.TimesheetHeaderID and tra.IsFinalisedHours = 1
--	INNER JOIN TimesheetRateAdjustmentItem trai ON tra.ID= trai.TimesheetRateAdjustmentID
--	INNER JOIN LoadingRate lr ON trai.RateID= lr.ID
--	where 		
--		@timesheetIncluded=1
--		--and e.IsDeleted=0 
--		and e.IsPlaceholder=0
--		and lr.IsNormalRate!=1
--		and tra.NormalRate is not null
--		and ((dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.FromDate)=ewh.ID and dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.ToDate)=ewh.ID) or (dbo.fnGetWorkHeaderInPeriod(e.id, pc.FromDate, pc.ToDate)=ewh.id))
--		and ts.Code='A'
--		and (isnull(lr1.Value,0)= lr.Value) and (isnull(lr1.Code,'')!=lr.Code)
--		and isnull(pg.ID, 0)=@payGroupID		
--		AND (((@status='O') AND (th.ProcessedPayCycleID is null and pc.ToDate<=@toDate ))
--		OR ((@status='C') AND th.ProcessedPayCycleID = @paycycleID))	
--
UNION
	select
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		th.ID as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		lr.Code as PayCode,
		lr.Description as PayCodeDescription,
		pc.FromDate as _date,
		pc.FromDate as _date1,
		pc.ToDate as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		(isnull(trai.Balance,0)) as Amount,
		(isnull(trai.Balance,0)) as totalAmount,
		1 as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'timesheet' as type,
		0 as CompRate,
		0 as GovRate,
		isnull(c.Code, '') as costCentre,
		0 as requestID,
		'' as systemCode		
	from Employee e
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1
	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	INNER JOIN TimesheetHeader th ON th.EmployeeID= e.id
	INNER JOIN Timesheetsummary ths ON th.ID= ths.TimesheetHeaderID and ths.Week is null
	LEFT OUTER JOIN LoadingRate lr1 ON ths.OvertimeRateID = lr1.ID
	LEFT OUTER JOIN CostCentres c ON th.CostCentreID= c.ID
	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
	LEFT OUTER JOIN PayrollCycleGroups pg ON pc.PayrollCycleGroupID= pg.ID
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
	INNER JOIN TimesheetRateAdjustment tra ON th.ID= tra.TimesheetHeaderID and tra.IsFinalisedHours = 1
	INNER JOIN TimesheetRateAdjustmentItem trai ON tra.ID= trai.TimesheetRateAdjustmentID
	INNER JOIN LoadingRate lr ON trai.RateID= lr.ID
	where 		
		@timesheetIncluded=1
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and lr.IsNormalRate!=1
		and tra.NormalRate is not null
		and ((dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.FromDate)=ewh.ID and dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.ToDate)=ewh.ID) or (dbo.fnGetWorkHeaderInPeriod(e.id, pc.FromDate, pc.ToDate)=ewh.id))
		and ts.Code='A'
		--and (isnull(lr1.Value,0)!= lr.Value or isnull(lr1.Code,'')= lr.Code) 
		and isnull(pg.ID, 0)=@payGroupID		
		AND (((@status='O') AND (th.ProcessedPayCycleID is null and pc.ToDate<=@toDate ))
		OR ((@status='C') AND th.ProcessedPayCycleID = @paycycleID))
-- overtime rate
--UNION
--	select
--		isnull(e.PayrollID,'') as payrollID,
--		e.id as EmployeeID,		
--		th.ID as detailID,
--		e.displayname as DisplayName,
--		e.surname as Surname,
--		lr1.Code as PayCode,
--		lr1.Description as PayCodeDescription,
--		pc.FromDate as _date,
--		pc.FromDate as _date1,
--		pc.ToDate as _todate,
--		@fromDate as FromDate,
--		@toDate as ToDate,
--		th.OvertimeHours as Amount,
--		th.OvertimeHours as totalAmount,
--		1 as paycycle,
--		--0 as LeaveDetailID,
--		2 as isPayout,
--		'timesheet' as type,
--		0 as CompRate,
--		0 as GovRate,
--		isnull(c.Code, '') as costCentre,
--		0 as requestID,
--		'' as systemCode		
--	from Employee e
--	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1
--	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
--	INNER JOIN TimesheetHeader th ON th.EmployeeID= e.id
--	INNER JOIN Timesheetsummary ths ON th.ID= ths.TimesheetHeaderID and ths.Week is null
--	LEFT OUTER JOIN LoadingRate lr1 ON ths.OvertimeRateID = lr1.ID
--	LEFT OUTER JOIN CostCentres c ON th.CostCentreID= c.ID
--	INNER JOIN PayrollCycle pc ON th.PayrollCycleID= pc.ID
--	LEFT OUTER JOIN PayrollCycleGroups pg ON pc.PayrollCycleGroupID= pg.ID
--	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.ID
--	INNER JOIN TimesheetRateAdjustment tra ON th.ID= tra.TimesheetHeaderID and tra.IsFinalisedHours = 1
--	INNER JOIN TimesheetRateAdjustmentItem trai ON tra.ID= trai.TimesheetRateAdjustmentID
--	INNER JOIN LoadingRate lr ON trai.RateID= lr.ID
--	where 		
--		@timesheetIncluded=1
--		--and e.IsDeleted=0 
--		and e.IsPlaceholder=0
--		and th.OvertimeHours !=0
--		and lr.IsNormalRate!=1
--		and tra.NormalRate is not null
--		and ((dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.FromDate)=ewh.ID and dbo.fnGetWorkHourHeaderIDByDay(e.id, pc.ToDate)=ewh.ID) or (dbo.fnGetWorkHeaderInPeriod(e.id, pc.FromDate, pc.ToDate)=ewh.id))
--		and ts.Code='A'
--		--and th.PayrollCycleID= @paycycleID		
--		and isnull(pg.ID, 0)=@payGroupID
--		and lr1.Value= lr.Value and lr1.Code!= lr.Code
--		AND (((@status='O') AND (th.ProcessedPayCycleID is null and pc.ToDate<=@toDate ))
--		OR ((@status='C') AND th.ProcessedPayCycleID = @paycycleID))	
-- expense 
UNION
	select
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		ecd.ID as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		@nontaxexpenseCode as PayCode,
		@nontaxexpenseCodeDesc as PayCodeDescription,
		ecd.ExpenseDate as _date,
		ech.ExpenseClaimDate as _date1,
		ecd.ExpenseDate as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		ecd.TotalMileage* ecd.GovernmentTravelRate as Amount,
		ecd.TotalMileage - dbo.fnGetMileageAbove(e.id, ecd.ExpenseDate, @startTaxableDate, @endTaxableDate, ecd.ID) as totalAmount,
		isnull(ecd.PayCycleID,0) as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'claim' as type,
		ecd.CompanyTravelRate as CompRate,
		ecd.GovernmentTravelRate as GovRate,
		isnull(c.Code, '') as costCentre,
		ech.ID as requestID,
		'' as systemCode	
	from Employee e
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1
	inner join PayrollCycleGroups pg on ewh.PayRollCycle= pg.ID and pg.id= @payGroupID
	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	INNER JOIN ExpenseClaimHeader ech ON e.id= ech.EmployeeID
	INNER JOIN ExpenseClaimDetail ecd ON ech.id= ecd.ExpenseClaimHeaderID
	LEFT OUTER JOIN CostCentres c ON ecd.CostCentreID= c.ID
	INNER JOIN ExpenseStatus es ON ecd.ExpenseStatusID= es.ID
	where 		
		@claimIncluded=1
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and ech.ClaimType=2
		and es.Code='A'
		and dbo.fnGetWorkHourHeaderIDByDay(e.id, ech.ExpenseClaimDate)=ewh.ID 
		AND (((@status='O') AND (ech.ExpenseClaimDate<=@toDate AND ecd.PayCycleID is null)) OR ((@status='C') AND ecd.PayCycleID= @paycycleID))	
		and ep.primaryposition='Y' and ep.IsDeleted=0	
		--and (@chkPrevious=1 OR (@chkPrevious=0 AND ech.ExpenseClaimDate>=@fromDate AND ech.ExpenseClaimDate<=@toDate))
UNION
	select
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		ecd.ID as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		@expenseCode as PayCode,
		@expenseCodeDesc as PayCodeDescription,
		ecd.ExpenseDate as _date,
		ech.ExpenseClaimDate as _date1,
		ecd.ExpenseDate as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		ecd.ExpenseAmount -ecd.TotalMileage* ecd.GovernmentTravelRate as Amount,
		ecd.TotalMileage - dbo.fnGetMileageAbove(e.id, ecd.ExpenseDate, @startTaxableDate, @endTaxableDate, ecd.ID)  as totalAmount,
		isnull(ecd.PayCycleID,0) as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'claim' as type,
		ecd.CompanyTravelRate as CompRate,
		ecd.GovernmentTravelRate as GovRate,
		isnull(c.Code, '') as costCentre,
		ech.ID as requestID,
		'' as systemCode	
	from Employee e
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1
	inner join PayrollCycleGroups pg on ewh.PayRollCycle= pg.ID and pg.id= @payGroupID
	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	INNER JOIN ExpenseClaimHeader ech ON e.id= ech.EmployeeID
	INNER JOIN ExpenseClaimDetail ecd ON ech.id= ecd.ExpenseClaimHeaderID
	LEFT OUTER JOIN CostCentres c ON ecd.CostCentreID= c.ID
	INNER JOIN ExpenseStatus es ON ecd.ExpenseStatusID= es.ID
	where 		
		@claimIncluded=1
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and ecd.GovernmentTravelRate<ecd.CompanyTravelRate
		and ech.ClaimType=2
		and dbo.fnGetWorkHourHeaderIDByDay(e.id, ech.ExpenseClaimDate)=ewh.ID 
		and es.Code='A'
		AND (((@status='O') AND (ech.ExpenseClaimDate<=@toDate AND ecd.PayCycleID is null)) OR ((@status='C') AND ecd.PayCycleID= @paycycleID))	
		and ep.primaryposition='Y' and ep.IsDeleted=0
		--and (@chkPrevious=1 OR (@chkPrevious=0 AND ech.ExpenseClaimDate>=@fromDate AND ech.ExpenseClaimDate<=@toDate))
UNION
	select
		isnull(e.PayrollID,'') as payrollID,
		e.id as EmployeeID,		
		ecd.ID as detailID,
		e.displayname as DisplayName,
		e.surname as Surname,
		@yearExpenseCode as PayCode,
		@yearExpenseCodeDesc as PayCodeDescription,
		ecd.ExpenseDate as _date,
		ech.ExpenseClaimDate as _date1,
		ecd.ExpenseDate as _todate,
		@fromDate as FromDate,
		@toDate as ToDate,
		(dbo.fnGetMileageAbove(e.id, ecd.ExpenseDate, @startTaxableDate, @endTaxableDate, ecd.ID) ) * @paidRate as Amount,
		dbo.fnGetMileageAbove(e.id, ecd.ExpenseDate, @startTaxableDate, @endTaxableDate, ecd.ID)  as totalAmount,
		isnull(ecd.PayCycleID,0) as paycycle,
		--0 as LeaveDetailID,
		2 as isPayout,
		'claim' as type,
		ecd.CompanyTravelRate as CompRate,
		ecd.GovernmentTravelRate as GovRate,
		isnull(c.Code, '') as costCentre,
		ech.ID as requestID,
		'' as systemCode	
	from Employee e
	inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID=e.id and ewh.ProcessPayroll=1
	inner join PayrollCycleGroups pg on ewh.PayRollCycle= pg.ID and pg.id= @payGroupID
	INNER JOIN EmployeePosition ep on e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	INNER JOIN ExpenseClaimHeader ech ON e.id= ech.EmployeeID
	INNER JOIN ExpenseClaimDetail ecd ON ech.id= ecd.ExpenseClaimHeaderID
	LEFT OUTER JOIN CostCentres c ON ecd.CostCentreID= c.ID
	INNER JOIN ExpenseStatus es ON ecd.ExpenseStatusID= es.ID
	where 		
		@claimIncluded=1
		--and e.IsDeleted=0 
		and e.IsPlaceholder=0
		and dbo.fnGetMileageAbove(e.id, ecd.ExpenseDate, @startTaxableDate, @endTaxableDate, ecd.ID) >0
		and ech.ClaimType=2
		and dbo.fnGetWorkHourHeaderIDByDay(e.id, ech.ExpenseClaimDate)=ewh.ID 
		and es.Code='A'
		AND (((@status='O') AND (ech.ExpenseClaimDate<=@toDate AND ecd.PayCycleID is null)) OR ((@status='C') AND ecd.PayCycleID= @paycycleID))	
		and ep.primaryposition='Y' and ep.IsDeleted=0
		--and (@chkPrevious=1 OR (@chkPrevious=0 AND ech.ExpenseClaimDate>=@fromDate AND ech.ExpenseClaimDate<=@toDate))
	) as Result 
	WHERE (@chkPrevious=1 OR (@chkPrevious=0 AND Result._date1>=@fromDate AND Result._date1<=@toDate))
	ORDER  BY 
			CASE WHEN @sortBy = 'name' THEN Result.DisplayName END,
			CASE WHEN @sortBy = 'surname' THEN Result.Surname END ASC,		
			CASE WHEN @sortBy = 'payrollID' THEN Result.payrollID END ,
			Result.EmployeeID, Result.payrollID, Result.PayCode, Result._date, Result.type desc 	
			
END

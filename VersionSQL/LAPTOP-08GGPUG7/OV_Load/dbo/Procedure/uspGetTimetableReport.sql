/****** Object:  Procedure [dbo].[uspGetTimetableReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTimetableReport] 
	-- Add the parameters for the stored procedure here
	@empID varchar(max), @payrollCycleGroupID int, @fromDate datetime, @toDate datetime, @divisionList varchar(max), @departmentList varchar(max), @locationList varchar(max), @typeList varchar(max), @statusList varchar(max), @timesheetStatus varchar(max), @sortBy varchar(max), @commentChk int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @empIDTable TABLE(id varchar(max));
	DECLARE @divisionTable TABLE(division varchar(max));
	DECLARE @statusTable TABLE(status varchar(max));	
	DECLARE @typeTable TABLE(type varchar(max));
	DECLARE @departmentTable TABLE(department varchar(max));	
	DECLARE @locationTable TABLE(location varchar(max));
	DECLARE @timesheetStatusTable TABLE(timesheetStatus varchar(max));	
	DECLARE @headerTable TABLE (id int); 
	INSERT INTO @headerTable(id) SELECT p.ID FROM PayrollCycle p WHERE p.PayrollCycleGroupID=@payrollCycleGroupID AND p.ToDate<=@toDate AND p.FromDate>=@fromDate

	IF CHARINDEX(',', @empID, 0) > 0 BEGIN
		INSERT INTO @empIDTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@empID, ',');	
    END
    ELSE IF LEN(@empID) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @empIDTable(id) VALUES(@empID);	
    END

	IF CHARINDEX(',', @divisionList, 0) > 0 BEGIN
		INSERT INTO @divisionTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@divisionList, ',');	
    END
    ELSE IF LEN(@divisionList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @divisionTable(division) VALUES(@divisionList);	
    END
	
	IF CHARINDEX(',', @statusList, 0) > 0 BEGIN
		INSERT INTO @statusTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@statusList, ',');	
    END
    ELSE IF LEN(@statusList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @statusTable(status) VALUES(@statusList);	
    END	

	IF CHARINDEX(',', @typeList, 0) > 0 BEGIN
		INSERT INTO @typeTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@typeList, ',');	
    END
    ELSE IF LEN(@typeList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @typeTable(type) VALUES(@typeList);	
    END	

	IF CHARINDEX(',', @departmentList, 0) > 0 BEGIN
		INSERT INTO @departmentTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@departmentList, ',');	
    END
    ELSE IF LEN(@departmentList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @departmentTable(department) VALUES(@departmentList);	
    END

	IF CHARINDEX(',', @timesheetStatus, 0) > 0 BEGIN
		INSERT INTO @timesheetStatusTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@timesheetStatus, ',');	
    END
    ELSE IF LEN(@timesheetStatus) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @timesheetStatusTable(timesheetStatus) VALUES(@timesheetStatus);	
    END

	IF CHARINDEX(',', @locationList, 0) > 0 BEGIN
		INSERT INTO @locationTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@locationList, ';');	
    END
    ELSE IF LEN(@locationList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @locationTable(location) VALUES(@locationList);	
    END
    -- Insert statements for procedure here	
	DECLARE @timesheetWithComment TABLE(id int);
	DECLARE @dateTable TABLE ([date] DateTime);
	DECLARE @StartDate DATE = @fromDate;
	DECLARE @EndDate DATE = @toDate;
	INSERT INTO @dateTable SELECT  DATEADD(DAY, nbr - 1, @StartDate)
	FROM( SELECT ROW_NUMBER() OVER ( ORDER BY c.object_id ) AS Nbr
	FROM      sys.columns c
	) nbrs
	WHERE   nbr - 1 <= DATEDIFF(DAY, @StartDate, @EndDate)


	SELECT e.id as empID, 
	e.displayname, 
	e.surname,
	e.PayrollID,
	isnull(p.orgunit2,'') as posorgunit2,
	isnull(p.orgunit3,'') as posorgunit3,
	isnull(e.location, '') as location,
	e.status as status, 
	isnull(e.type,'') as emptype INTO #EmpList
	FROM Employee e 
	LEFT OUTER JOIN EmployeePosition ep ON e.id= ep.employeeid AND ep.primaryposition='Y' AND ep.IsDeleted=0
	LEFT OUTER JOIN Position p ON ep.positionid= p.id
	WHERE ((SELECT COUNT(*) FROM @departmentTable) = 0 OR case when isnull(p.orgunit3, '') = '' then '(Blank)' else p.orgunit3 end IN (SELECT * FROM @departmentTable))
	AND ((SELECT COUNT(*) FROM @divisionTable) = 0 OR case when isnull(p.orgunit2, '') = '' then '(Blank)' else p.orgunit2 end IN (SELECT * FROM @divisionTable))
	AND ((SELECT COUNT(*) FROM @locationTable) = 0 OR case when isnull(e.location, '') = '' then '(Blank)' else e.location end IN (SELECT * FROM @locationTable))
	AND ((SELECT COUNT(*) FROM @statusTable) = 0 OR e.status IN (SELECT * FROM @statusTable)) 
	AND ((SELECT COUNT(*) FROM @typeTable) = 0 OR e.type IN (SELECT * FROM @typeTable))
	AND (e.id IN (SELECT * FROM @empIDTable))

	DECLARE @timesheetHeaderTable table(headerID int, payrollCycleID int, statusID int, employeeID int);
	INSERT INTO @timesheetHeaderTable SELECT th.id, th.PayrollCycleID, ts.ID, th.EmployeeID
	FROM TimesheetHeader th 
	INNER JOIN TimesheetStatus ts ON th.TimesheetStatusID= ts.id
	WHERE th.PayrollCycleID in (SELECT * FROM @headerTable)
	AND (ts.Code IN (SELECT * FROM @timesheetStatusTable)) 
	--select * from @timesheetHeaderTable
	DECLARE @timesheetDayTable TABLE(headerID int, payrollCycleID int, statusID int, _date datetime, employeeID int)
	DECLARE @headerID int;
	DECLARE @payCycleID int;
	DECLARE @statusID int;
	DECLARE @employeeID int;
	DECLARE c CURSOR FOR SELECT headerID, payrollCycleID, statusID, employeeID FROM @timesheetHeaderTable
	OPEN c
	FETCH FROM c INTO @headerID, @payCycleID, @statusID, @employeeID
	WHILE @@FETCH_STATUS=0
	BEGIN
		DECLARE @from datetime= (SELECT FromDate FROM PayrollCycle WHERE id= @payCycleID);
		DECLARE @to datetime= (SELECT ToDate FROM PayrollCycle WHERE id= @payCycleID);
		INSERT INTO @timesheetDayTable SELECT @headerID, @payCycleID,@statusID, d.date, @employeeID
		FROM @dateTable d
		WHERE d.date>=@from AND d.date<=@to
		FETCH FROM c INTO @headerID, @payCycleID, @statusID, @employeeID
	END
	CLOSE c;
	DEALLOCATE c;
	--select * from @timesheetDayTable
	INSERT INTO @timesheetWithComment(id) (SELECT th.ID FROM TimesheetHeader th
	INNER JOIN #EmpList e ON th.EmployeeID= e.empID
	LEFT OUTER JOIN TimesheetComments tc ON th.id= tc.TimesheetHeaderID
	LEFT OUTER JOIN TimesheetApproverComments tac ON th.ID= tac.TimesheetHeaderID
	WHERE (tc.ID is not null or tac.ID is not null)
	and th.PayrollCycleID in (SELECT * from @headerTable))

SELECT * FROM(
--get timesheet day
	SELECT 
	0 as dayNo,
	e.empID as empID, 
	e.displayname, 
	e.surname,
	e.PayrollID,
	e.posorgunit2,
	e.posorgunit3,
	e.location,
	e.status as status, 
	e.emptype,
	tsh.headerID as timesheetheaderid,
	tsh.payrollCycleID as PayrollCycleID, 
	'' as code,
	pc.Description, 
	pc.FromDate as fromDate,
	pc.ToDate as toDate,
	tsh._date as date, 
	isnull(tsd.startTime,'') as StartTime,
	isnull(tsd.FinishTime,'') as FinishTime,
	isnull(tsd.SwipeCheckIn,'') as swipeIn,
	isnull(tsd.SwipeCheckOut,'') as swipeOut,
	isnull(tsd.Breaks, 0)as Breaks,	
	case when tsd.StartTime='' then 0 else isnull(tsd.Hours,0) end as Hours,
	'timesheet' as type,
	DATENAME(weekday, tsh._date) as daycode,
	isnull(tc.ID,0) as commentid,
	isnull(tc.Comment,'') as comment,
	isnull(tc.DateFor,'') as CommentDate,
	ewh.ApplyOvertimeOption  as overtimeoption,
	ewh.AllowOvertime as allowovertime,
	ewh.EnableSwipeCard as enableSwipe,
	0 as leaveID,
	pp.Code as payCycleCode,
	isnull(tsm.PlannedWorkHours,0) as NormalHours,
	isnull(tsm.WorkedHours,0) as WorkedHours,
	isnull(tsm.PaidLeaveHours,0) as PaidLeaveHours,
	isnull(tsm.Total,0) as Total,
	isnull(tsm.Overtime,0) as Overtime,
	isnull(tsm.UnpaidLeaveHours,0) as UnpaidLeaveHours,
	pc.Description as payCycle,
	ts.Description as timesheetStatus,
	isnull(tsd.DailyOvertime,0) as DailyOvertime 
	FROM 
	--@dateTable d LEFT OUTER JOIN 
	@timesheetDayTable tsh 
	--tsd ON d.date= tsd.date
	LEFT OUTER JOIN TimesheetDay tsd ON tsh.headerID = tsd.TimesheetHeaderID and tsh._date= tsd.date 
	INNER JOIN TimesheetStatus ts ON tsh.statusID = ts.ID
	LEFT OUTER JOIN TimesheetSummary tsm ON tsh.headerID= tsm.TimesheetHeaderID AND tsm.Week IS NULL
	left outer JOIN TimesheetComments tc ON tsd.date= tc.DateFor and tc.TimesheetHeaderID= tsh.headerID
	INNER JOIN PayrollCycle pc ON tsh.PayrollCycleID= pc.ID
	INNER JOIN PayrollCyclePeriods pp ON pc.PayrollCyclePeriodID= pp.ID
	INNER JOIN #EmpList e ON tsh.employeeID= e.empID
	INNER JOIN EmployeeWorkHoursHeader ewh ON e.empID= ewh.EmployeeID 
	and dbo.fnGetWorkHourHeaderIDByDay(e.empID, tsh._date)=ewh.ID
	--WHERE tsh.PayrollCycleID in (SELECT * FROM @headerTable)
	--AND (ts.Code IN (SELECT * FROM @timesheetStatusTable)) 
	--and pc.FromDate<=d.date and pc.Todate>=d.date
	
UNION

	SELECT 
	0 as dayNo,
	e.empID as empID, 
	e.displayname, 
	e.surname,
	e.PayrollID,
	e.posorgunit2,
	e.posorgunit3,
	e.location,
	e.status as status, 
	e.emptype,
	tsh.headerID as timesheetheaderid,
	tsh.PayrollCycleID as PayrollCycleID, 
	'' as code,
	pc.Description, 
	pc.FromDate as fromDate,
	pc.ToDate as toDate,
	tsh._date as date, 
	isnull(tsd.startTime,'') as StartTime,
	isnull(tsd.FinishTime,'') as FinishTime,
	isnull(tsd.SwipeCheckIn,'') as swipeIn,
	isnull(tsd.SwipeCheckOut,'') as swipeOut,
	isnull(tsd.Breaks, 0)as Breaks,	
	case when tsd.StartTime='' then 0 else isnull(tsd.Hours,0) end as Hours,
	'timesheet' as type,
	DATENAME(weekday, tsh._date) as daycode,
	0 as commentid,
	'' as comment,
	'' as CommentDate,
	ewh.ApplyOvertimeOption  as overtimeoption,
	ewh.AllowOvertime as allowovertime,
	ewh.EnableSwipeCard as enableSwipe,
	0 as leaveID, 
	pp.Code as payCycleCode,
	isnull(tsm.PlannedWorkHours,0) as NormalHours,
	isnull(tsm.WorkedHours,0) as WorkedHours,
	isnull(tsm.PaidLeaveHours,0) as PaidLeaveHours,
	isnull(tsm.Total,0) as Total,
	isnull(tsm.Overtime,0) as Overtime,
	isnull(tsm.UnpaidLeaveHours,0) as UnpaidLeaveHours,
	pc.Description as payCycle,
	ts.Description as timesheetStatus,
	isnull(tsd.DailyOvertime,0) as DailyOvertime
	FROM @timesheetDayTable tsh 
	--tsd ON d.date= tsd.date
	LEFT OUTER JOIN TimesheetDay tsd ON tsh.headerID = tsd.TimesheetHeaderID and tsh._date= tsd.date 
	INNER JOIN TimesheetStatus ts ON tsh.statusID = ts.ID
	LEFT OUTER JOIN TimesheetSummary tsm ON tsh.headerID= tsm.TimesheetHeaderID AND tsm.Week IS NULL
	--left outer JOIN TimesheetComments tc ON tsd.date= tc.DateFor and tc.TimesheetHeaderID= tsh.headerID
	INNER JOIN PayrollCycle pc ON tsh.PayrollCycleID= pc.ID
	INNER JOIN PayrollCyclePeriods pp ON pc.PayrollCyclePeriodID= pp.ID
	INNER JOIN #EmpList e ON tsh.employeeID= e.empID
	INNER JOIN EmployeeWorkHoursHeader ewh ON e.empID= ewh.EmployeeID 
	and isnull(dbo.fnGetWorkHourHeaderIDByDay(e.empID, tsh._date),0)!=ewh.ID and dbo.fnGetWorkHeaderInPeriod(e.empID, pc.FromDate, pc.ToDate)= ewh.id	
	--WHERE tsh.PayrollCycleID in (SELECT * FROM @headerTable)	
	--AND (ts.Code IN (SELECT * FROM @timesheetStatusTable)) 
	--and pc.FromDate<=d.date and pc.Todate>=d.date
--get leave day
UNION
	SELECT 
	-1 as dayNo,
	e.empID as empID, 
	e.displayname, 
	e.surname,
	e.PayrollID,
	e.posorgunit2,
	e.posorgunit3,
	e.location,
	e.status as status, 
	e.emptype,
	tsh.ID as timesheetheaderid,
	tsh.PayrollCycleID, 
	
	lt.Code as code,
	lt.ReportDescription as description, 
	pc.FromDate as fromDate,
	pc.ToDate as toDate,
	lrd.LeaveDateFrom as Date, 
	lr.PeriodFrom as StartTime,
	lr.PeriodTo as FinishTime,
	isnull(tsd.SwipeCheckIn,'') as swipeIn,
	isnull(tsd.SwipeCheckOut,'') as swipeOut,
	0 as Breaks,	
	lrd.Duration as Hours,
	'leave' as type,
	DATENAME(weekday, lrd.LeaveDateFrom) as daycode,
	0 as commentid,
	'' as comment,
	'' as CommentDate,
	ewh.ApplyOvertimeOption as overtimeoption,
	ewh.AllowOvertime as allowovertime,
	ewh.EnableSwipeCard as enableSwipe,
	lrd.ID as leaveID, 
	pp.Code as payCycleCode,
	isnull(tsm.PlannedWorkHours,0) as NormalHours,
	isnull(tsm.WorkedHours,0) as WorkedHours,
	isnull(tsm.PaidLeaveHours,0) as PaidLeaveHours,
	isnull(tsm.Total,0) as Total,
	isnull(tsm.Overtime,0) as Overtime,
	isnull(tsm.UnpaidLeaveHours,0) as UnpaidLeaveHours,
	pc.Description as payCycle,
	ts.Description as timesheetStatus,
	isnull(tsd.DailyOvertime,0) as DailyOvertime
	FROM TimesheetDay tsd
	INNER JOIN TimesheetHeader tsh ON tsh.ID = tsd.TimesheetHeaderID
	INNER JOIN TimesheetStatus ts ON tsh.TimesheetStatusID = ts.ID
	LEFT OUTER JOIN TimesheetSummary tsm ON tsh.ID= tsm.TimesheetHeaderID AND tsm.Week IS NULL
	INNER JOIN PayrollCycle pc ON tsh.PayrollCycleID= pc.ID
	INNER JOIN PayrollCyclePeriods pp ON pc.PayrollCyclePeriodID = pp.ID
	INNER JOIN #EmpList e ON tsh.EmployeeID= e.empID
	INNER JOIN EmployeeWorkHoursHeader ewh ON e.empID= ewh.EmployeeID and dbo.fnGetWorkHourHeaderIDByDay(e.empID, tsd.Date)=ewh.ID	
	INNER JOIN LeaveRequest lr ON e.empID= lr.EmployeeID
	INNER JOIN LeaveRequestDetail lrd ON lr.ID= lrd.LeaveRequestID
	INNER JOIN LeaveType lt on lr.LeaveTypeID= lt.ID
	INNER JOIN  LeaveStatus ls on lr.LeaveStatusID= ls.ID
	WHERE tsh.PayrollCycleID in (SELECT * FROM @headerTable)
	and ls.Code='A'
	
	AND (lrd.LeaveDateFrom>=pc.FromDate AND lrd.LeaveDateFrom<=pc.ToDate)
	AND (ts.Code IN (SELECT * FROM @timesheetStatusTable)) 
UNION
	SELECT 
	-1 as dayNo,
	e.empID as empID, 
	e.displayname, 
	e.surname,
	e.PayrollID,
	e.posorgunit2,
	e.posorgunit3,
	e.location,
	e.status as status, 
	e.emptype,
	tsh.ID as timesheetheaderid,
	tsh.PayrollCycleID, 
	
	lt.Code as code,
	lt.ReportDescription as description, 
	pc.FromDate as fromDate,
	pc.ToDate as toDate,
	
	h.Date as Date, 
	'' as StartTime,
	'' as FinishTime,
	isnull(tsd.SwipeCheckIn,'') as swipeIn,
	isnull(tsd.SwipeCheckOut,'') as swipeOut,
	0 as Breaks,	
	iif(dbo.fnGetHoursInDay(e.empID, h.Date)- (case when tsd.StartTime='' then 0 else isnull(tsd.Hours,0) end)>0,dbo.fnGetHoursInDay(e.empID, h.Date)- (case when tsd.StartTime='' then 0 else isnull(tsd.Hours,0) end),0) as Hours,
	'leave' as type,
	DATENAME(weekday, h.Date) as daycode,
	0 as commentid,
	'' as comment,
	'' as CommentDate,
	ewh.ApplyOvertimeOption as overtimeoption,
	ewh.AllowOvertime as allowovertime,
	ewh.EnableSwipeCard as enableSwipe,
	0 as leaveID, 
	pp.Code as payCycleCode,
	isnull(tsm.PlannedWorkHours,0) as NormalHours,
	isnull(tsm.WorkedHours,0) as WorkedHours,
	isnull(tsm.PaidLeaveHours,0) as PaidLeaveHours,
	isnull(tsm.Total,0) as Total,
	isnull(tsm.Overtime,0) as Overtime,
	isnull(tsm.UnpaidLeaveHours,0) as UnpaidLeaveHours,
	pc.Description as payCycle,
	ts.Description as timesheetStatus,
	isnull(tsd.DailyOvertime,0) as DailyOvertime
	FROM TimesheetDay tsd
	INNER JOIN TimesheetHeader tsh ON tsh.ID = tsd.TimesheetHeaderID
	INNER JOIN TimesheetStatus ts ON tsh.TimesheetStatusID= ts.ID
	LEFT OUTER JOIN TimesheetSummary tsm ON tsh.ID= tsm.TimesheetHeaderID AND tsm.Week IS NULL
	INNER JOIN PayrollCycle pc ON tsh.PayrollCycleID= pc.ID
	INNER JOIN PayrollCyclePeriods pp ON pc.PayrollCyclePeriodID = pp.ID
	INNER JOIN #EmpList e ON tsh.EmployeeID= e.empID	
	INNER JOIN EmployeeWorkHoursHeader ewh ON e.empID= ewh.EmployeeID and dbo.fnGetWorkHourHeaderIDByDay(e.empID, tsd.Date)=ewh.ID
	LEFT OUTER JOIN HolidayRegion hr ON ewh.HolidayRegionID= hr.ID
	LEFT OUTER JOIN Holiday h ON hr.ID= h.HolidayRegionID, LeaveType lt
		
	WHERE 
	tsh.PayrollCycleID in (SELECT * FROM @headerTable)	
	and ewh.HasPublicHolidays=1
	and ewh.ModuleLeave=1
	and h.Date= tsd.Date
	
	and lt.SystemCode='P'
	AND (h.Date>=pc.FromDate AND h.Date<=pc.ToDate)
	AND (ts.Code IN (SELECT * FROM @timesheetStatusTable)) 
	) as Result 
	WHERE (@commentChk=0 or (@commentChk=1 and Result.timesheetheaderid IN (SELECT id FROM @timesheetWithComment)))
	order by 
		CASE WHEN @sortBy = 'name' THEN Result.DisplayName END,
		CASE WHEN @sortBy = 'surname' THEN Result.Surname END ASC,		
		CASE WHEN @sortBy = 'payrollID' THEN Result.payrollID END DESC,
		CASE WHEN @sortBy = 'paycycle' THEN Result.fromDate END asc,
	Result.empID, Result.payCycle, Result.Date, Result.code
	if (OBJECT_ID('tempdb..#EmpList') is not null)			
		drop table #EmpList
END

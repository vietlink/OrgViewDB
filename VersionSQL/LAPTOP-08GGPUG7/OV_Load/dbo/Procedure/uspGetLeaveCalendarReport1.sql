/****** Object:  Procedure [dbo].[uspGetLeaveCalendarReport1]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetLeaveCalendarReport1] 
	-- Add the parameters for the stored procedure here
 @startDate datetime, @toDate dateTime, @divisionFilter varchar(max), @departmentFilter varchar(max), @locationFilter varchar(max), @leaveTypeFilter varchar(max), @groupBy varchar(max), @sortBy varchar (max), @includeNotYetApprove int, @includeNoLeaveBooked int, @includeRejectedLeave int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @divisionTable table (idDivisionTable varchar(max));
	declare @departmentTable table (idDepartmentTable varchar(max));
	declare @locationTable table (idLocationTable varchar(max));
	declare @leaveTypeTable table (idLeaveType varchar(max));
	
	declare @timeTable table (id int, value datetime, daycode varchar(10));

	IF CHARINDEX(',', @divisionFilter, 0) > 0 BEGIN
		INSERT INTO @divisionTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@divisionFilter, ',');	
    END
    ELSE IF LEN(@divisionFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @divisionTable(idDivisionTable) VALUES(@divisionFilter);	
    END

	IF CHARINDEX(',', @departmentFilter, 0) > 0 BEGIN
		INSERT INTO @departmentTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@departmentFilter, ',');	
    END
    ELSE IF LEN(@departmentFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @departmentTable(idDepartmentTable) VALUES(@departmentFilter);	
    END

	IF CHARINDEX(';', @locationFilter, 0) > 0 BEGIN
		INSERT INTO @locationTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@locationFilter, ';');	
    END
    ELSE IF LEN(@locationFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @locationTable(idLocationTable) VALUES(@locationFilter);	
    END

	IF CHARINDEX(';', @leaveTypeFilter, 0) > 0 BEGIN
		INSERT INTO @leaveTypeTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@leaveTypeFilter, ';');	
    END
    ELSE IF LEN(@leaveTypeFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @leaveTypeTable(idLeaveType) VALUES(@leaveTypeFilter);	
    END	
	DECLARE @dateRange table(_date datetime)
	DECLARE @tempDate datetime
	SET @tempDate= @startDate
	WHILE (@tempDate<=@toDate)
	BEGIN
		INSERT INTO @dateRange VALUES(@tempDate)
		SET @tempDate= @tempDate+1
	END
	-- get employee match the filter
	SELECT e.id, e.surname, e.displayname, e.location, p.id as posID, ep.id as empPosID, p.orgunit2, p.orgunit3, p.title,
	ewh.id as workHeaderID, ewh.HolidayRegionID
	 into #empList
	FROM Employee e 
	LEFT OUTER JOIN EmployeePosition ep ON e.id= ep.employeeid and ep.isdeleted = 0 and ep.primaryposition='Y'	
	LEFT OUTER JOIN Position p ON ep.positionid= p.id
	INNER JOIN EmployeeWorkHoursHeader ewh ON e.id= ewh.EmployeeID and dbo.fnGetWorkHeaderInPeriod(e.id, @startDate, @toDate)= ewh.ID
	
	WHERE e.status<>'Deleted' 
	and e.displayname!='Vacant'
	AND ((SELECT COUNT(*) FROM @departmentTable) = 0 OR case when isnull(p.orgunit3, '') = '' then '(Blank)' else p.orgunit3 end IN (SELECT * FROM @departmentTable))
	AND ((SELECT COUNT(*) FROM @divisionTable) = 0 OR case when isnull(p.orgunit2, '') = '' then '(Blank)' else p.orgunit2 end IN (SELECT * FROM @divisionTable))
	AND ((SELECT COUNT(*) FROM @locationTable) = 0 OR case when isnull(e.location, '') = '' then '(Blank)' else e.location end IN (SELECT * FROM @locationTable))

	SELECT
		e.id as EmployeeID,
		e.posID as PositionID,
		e.empPosID as EpID,		
		t.[ReportDescription] as LeaveType,
		t.Code as LeaveTypeCode,
		t.BackgroundColour as BackgroundColour,
		t.FontColour as FontColour,
		t.ID as LeaveID,
		s.[Description] as LeaveStatus,
		s.ShortDescription as LeaveDescription,		
		lrd.LeaveDateFrom as DateFrom,
		lrd.LeaveDateTo as DateTo,					
		lrd.Duration as ActualHours,		
		r.ID as RequestID,
		e.displayname as DisplayName,
		e.title as title,
		r.PeriodFrom as PeriodFrom,
		r.PeriodTo as PeriodTo,		
		s.Code as leavestatusshortdescription,
		e.orgunit3 as orgunit3,
		e.orgunit2 as orgunit2,
		e.location as location,
		e.surname as surname,
		1 as BookedLeave,
		lrd.EmployeeWorkHoursHeaderID as workHeaderID,
		ew.WorkHours as workHour,
		isnull(dbo.fnCountMostLeaveForEmployeeInPeriod(e.id, @startDate, @toDate, @includeRejectedLeave, @includeNotYetApprove, @leaveTypeFilter),1) as _count
		 into #leaveRequest
	FROM
		LeaveRequest r
	INNER JOIN
		LeaveRequestDetail lrd
	ON
		lrd.LeaveRequestID = r.ID
	INNER JOIN
		LeaveType t
	ON
		r.LeaveTypeID = t.ID
	INNER JOIN
		LeaveStatus s
	ON
		r.LeaveStatusID = s.ID
	
	INNER JOIN
		#empList e
	ON
		e.ID = r.EmployeeID			
	INNER JOIN EmployeeWorkHours ew ON e.workHeaderID= ew.EmployeeWorkHoursHeaderID and ew.DayCode= DATENAME(dw, lrd.LeaveDateFrom) and ew.Week= dbo.fnGetWeekByHeaderDate(e.workHeaderID, lrd.LeaveDateFrom)
	WHERE
		r.IsCancelled = 0 		
		and ((s.Code!='R'  and @includeRejectedLeave=0) or (@includeRejectedLeave=1))
		and ((s.Code!='P' and @includeNotYetApprove=0) or (@includeNotYetApprove=1))
		and s.Code !='C'		
		AND lrd.LeaveDateFrom >= @startDate AND lrd.LeaveDateFrom <= @toDate
		--and dbo.fnGetHoursInDay(e.id, lrd.LeaveDateFrom) >0
		AND ((SELECT COUNT(*) FROM @leaveTypeTable) = 0 OR t.[ReportDescription] IN (SELECT * FROM @leaveTypeTable))

	SELECT * FROM(
	--get all leave request
	SELECT * FROM #leaveRequest
UNION 	
--people with no leave booked, get NWD
    SELECT
		e.id as EmployeeID,
		e.posID as PositionID,
		e.empPosID as EpID,		
		Null as LeaveType,
		Null as LeaveTypeCode,
		NULL as BackgroundColour,
		NULL as FontColour,
		Null as LeaveID,
		Null as LeaveStatus,
		Null as LeaveDescription,				
		d._date as DateFrom,
		d._date as DateTo,				
		0 as ActualHours,		
		NULL as RequestID,
		e.displayname as DisplayName,
		e.title as title,
		NULL as PeriodFrom,
		NULL as PeriodTo,
		null as leavestatusshortdescription,
		e.orgunit3 as orgunit3,
		e.orgunit2 as orgunit2,
		e.location as location,
		e.surname as surname,
		0 as BookedLeave,
		e.workHeaderID as workHeaderID,
		ew.WorkHours as workHour,
		isnull(dbo.fnCountMostLeaveForEmployeeInPeriod(e.id, @startDate, @toDate, @includeRejectedLeave, @includeNotYetApprove, @leaveTypeFilter),1) as _count
	FROM	
		#empList e
	INNER JOIN EmployeeWorkHours ew ON e.workHeaderID= ew.EmployeeWorkHoursHeaderID,@dateRange d	
	
	WHERE		
	--and ((ew.DateFrom<=@dateTo  and ew.DateTo>=@dateFrom) or (ew.DateFrom<=@dateTo and ew.DateTo is null)) 	
	ew.Enabled=0
	and ew.DayCode= DATENAME(dw, d._date) and ew.Week= dbo.fnGetWeekByHeaderDate(e.workHeaderID, d._date)
	and ((@includeNoLeaveBooked=0 and e.id IN (select l.EmployeeID from #leaveRequest l)) or @includeNoLeaveBooked=1)
		
	UNION
	--public holiday for employee with leave
SELECT
		e.id as EmployeeID,
		e.posID as PositionID,
		e.empPosID as EpID,		
		h.Description as LeaveType,
		t.SystemCode as LeaveTypeCode,
		t.BackgroundColour as BackgroundColour,
		t.FontColour as FontColour,
		t.ID as LeaveID,
		null as LeaveStatus,
		null as LeaveDescription,		
		h.Date as DateFrom,
		null as DateTo,				
		0 as ActualHours,		
		0  as RequestID,
		e.displayname  as DisplayName,
		e.title  as title,		
		null  as PeriodFrom,
		null  as PeriodTo,
		null  as leavestatusshortdescription,
		e.orgunit3  as orgunit3,
		e.orgunit2  as orgunit2,
		e.location  as location,
		e.surname  as surname,
		1 as BookedLeave,	
		e.workHeaderID as workHeaderID,
		ew.WorkHours as workHour,
		isnull(dbo.fnCountMostLeaveForEmployeeInPeriod(e.id, @startDate, @toDate, @includeRejectedLeave, @includeNotYetApprove, @leaveTypeFilter),1) as _count
	FROM LeaveType t, 		
	Holiday h 
	INNER JOIN HolidayRegion hr ON h.HolidayRegionID= hr.ID
	INNER JOIN #empList e ON e.HolidayRegionID= hr.ID 
	inner join EmployeeWorkHours ew on e.workHeaderID= ew.EmployeeWorkHoursHeaderID
	and ew.DayCode= DATENAME(dw, h.Date) and ew.Week= dbo.fnGetWeekByHeaderDate(e.workHeaderID, h.Date)
	WHERE t.SystemCode='P' 
	and ((@includeNoLeaveBooked=0 and e.id IN (select l.EmployeeID from #leaveRequest l)) or @includeNoLeaveBooked=1)
	and h.Date>=@startDate and h.Date<=@toDate
	AND ew.DayCode = DATENAME(dw, h.Date) and dbo.fnGetWorkHourHeaderIDByDay(e.id, h.Date)=e.workHeaderID
	
	AND ((SELECT COUNT(*) FROM @leaveTypeTable) = 0 OR t.[ReportDescription] IN (SELECT * FROM @leaveTypeTable))

	) as ResultSet		
	ORDER BY		
		CASE WHEN @groupBy = 'orgunit2' THEN ResultSet.orgunit2 END,		
		CASE WHEN @groupBy = 'orgunit3' THEN ResultSet.orgunit3 END,
		CASE WHEN @groupBy = 'location' THEN ResultSet.location END,
		CASE WHEN @groupBy = 'title' OR @sortBy='title' THEN ResultSet.title END,
		CASE WHEN @sortBy = 'displayname' THEN ResultSet.displayname END,				
		CASE WHEN @sortBy = 'surname' THEN ResultSet.surname END,
		ResultSet.EmployeeID, ResultSet.DateFrom

		if (OBJECT_ID('tempdb..#empList') is not null)			
		drop table #empList
	if (OBJECT_ID('tempdb..#leaveRequest') is not null)			
		drop table #leaveRequest

END

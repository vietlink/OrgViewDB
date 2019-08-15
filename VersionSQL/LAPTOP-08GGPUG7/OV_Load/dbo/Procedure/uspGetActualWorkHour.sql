/****** Object:  Procedure [dbo].[uspGetActualWorkHour]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetActualWorkHour] 
	-- Add the parameters for the stored procedure here
 @startDate datetime, @toDate dateTime, @divisionFilter varchar(max), @departmentFilter varchar(max), @locationFilter varchar(max), @employeeStatusFilter varchar(max), @employeeTypeFilter varchar(max),  @groupBy varchar(max), @sortBy varchar (max), @timesheetNotYetApprove int, @leaveNotYetApprove int, @payCycleID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @divisionTable table (idDivisionTable varchar(max));
	declare @departmentTable table (idDepartmentTable varchar(max));
	declare @locationTable table (idLocationTable varchar(max));	
	declare @employeeStatusTable table (idEmployeeStatusTable varchar(max));
	declare @employeeTypeTable table (idEmployeeTypeTable varchar(max));
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

	
	IF CHARINDEX(',', @employeeTypeFilter, 0) > 0 BEGIN
		INSERT INTO @employeeTypeTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@employeeTypeFilter, ',');	
    END
    ELSE IF LEN(@employeeTypeFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @employeeTypeTable(idEmployeeTypeTable) VALUES(@employeeTypeFilter);	
    END	

	IF CHARINDEX(',', @employeeStatusFilter, 0) > 0 BEGIN
		INSERT INTO @employeeStatusTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@employeeStatusFilter, ',');	
    END
    ELSE IF LEN(@employeeStatusFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @employeeStatusTable(idEmployeeStatusTable) VALUES(@employeeStatusFilter);	
    END		
select
	e.id as EmpID,
	e.displayname as displayname,
	e.surname as surname,
	isnull(e.location,'') as location,
	isnull(e.status,'') as empstatus,
	isnull(e.type,'') as emptype,
	p.title as title,
	isnull(p.orgunit2,'') as orgunit2,
	isnull(p.orgunit3,'') as orgunit3 into #empList
from Employee e
	left outer join EmployeePosition ep on e.id= ep.employeeid
	left outer join Position p on ep.positionid=p.id
where 
	ep.primaryposition='Y' and ep.IsDeleted=0		
	and ep.vacant='N'
	and e.IsPlaceholder!=1		
	--and p.iFlag=0
	and ((SELECT COUNT(*) FROM @employeeTypeTable) = 0 OR isnull(e.type, '(Blank)') IN (SELECT * FROM @employeeTypeTable))	
	AND ((SELECT COUNT(*) FROM @employeeStatusTable) = 0 OR e.status IN (SELECT * FROM @employeeStatusTable))
	AND ((SELECT COUNT(*) FROM @departmentTable) = 0 OR case when isnull(p.orgunit3, '') = '' then '(Blank)' else p.orgunit3 end IN (SELECT * FROM @departmentTable))
	AND ((SELECT COUNT(*) FROM @divisionTable) = 0 OR case when isnull(p.orgunit2, '') = '' then '(Blank)' else p.orgunit2 end IN (SELECT * FROM @divisionTable))
	AND ((SELECT COUNT(*) FROM @locationTable) = 0 OR case when isnull(e.location, '') = '' then '(Blank)' else e.location end IN (SELECT * FROM @locationTable))

select * into #tempEmp
from (
	select
		e.EmpID as EmpID,
		e.displayname as displayname,
		e.surname as surname,

		isnull(e.location,'') as location,
		isnull(e.empstatus,'') as empstatus,
		isnull(e.emptype,'') as emptype,
		e.title as title,
		isnull(e.orgunit2,'') as orgunit2,
		isnull(e.orgunit3,'') as orgunit3,
		th.ID as ID,		
		td.Date as StartDate,
		td.Date as EndDate,
		'' as daycode,		
		'0:'+cast(dbo.fnGetTimesheetHoursByDay(td.Date, e.EmpID) as varchar) as hours,		
		0 as _week,
		0 as weekmode,		
		'' as color,
		0 as isLeave			
	from 
		#empList e
		inner join TimesheetHeader th on th.EmployeeID= e.EmpID
		inner join TimesheetDay td on td.TimesheetHeaderID= th.ID
		inner join TimesheetStatus ts on th.TimesheetStatusID= ts.ID
	where 		
		((td.Date<=@toDate and td.Date>=@startDate))
		and ((ts.Code='A' and @timesheetNotYetApprove=0) or ((ts.Code!='R') and @timesheetNotYetApprove=1))
		and ((th.PayrollCycleID=@payCycleID and @payCycleID!=0) or (@payCycleID=0))	
UNION
	select
		e.EmpID as EmpID,
		e.displayname as displayname,
		e.surname as surname,

		isnull(e.location,'') as location,
		isnull(e.empstatus,'') as empstatus,
		isnull(e.emptype,'') as emptype,
		e.title as title,
		isnull(e.orgunit2,'') as orgunit2,
		isnull(e.orgunit3,'') as orgunit3,
		0 as ID,
		h.Date as StartDate,
		h.Date as EndDate,
		cast (DATENAME(dw, h.Date) as varchar) as daycode,		
		lt.systemcode+':'+cast (ew.WorkHours as varchar) as hours,
		ew.Week as _week,
		0 as weekmode,
		lt.BackgroundColour as color,
		1 as isLeave	
	from 
		#empList e		
		inner join TimesheetHeader th on th.EmployeeID= e.EmpID
		inner join TimesheetDay td on td.TimesheetHeaderID= th.ID
		inner join TimesheetStatus ts on th.TimesheetStatusID= ts.ID
		inner join EmployeeWorkHoursHeader ewh on ewh.EmployeeID= e.EmpID
		inner join EmployeeWorkHours ew on ew.EmployeeWorkHoursHeaderID=ewh.ID		
		inner join HolidayRegion hr on ewh.HolidayRegionID = hr.ID
		inner join Holiday h on hr.ID= h.HolidayRegionID AND ew.DayCode = DATENAME(dw, h.Date) and dbo.fnGetWorkHourHeaderIDByDay(e.EmpID, h.Date)=ewh.id and dbo.fnGetWeekByHeaderDate(ewh.ID, h.Date)=ew.Week
		, LeaveType lt 	
	where 		
		lt.SystemCode='P'
		and ewh.HasPublicHolidays=1
		and ((td.Date<=@toDate and td.Date>=@startDate))
		and ((ts.Code='A' and @timesheetNotYetApprove=0) or ((ts.Code!='R') and @timesheetNotYetApprove=1))
		and ((th.PayrollCycleID=@payCycleID and @payCycleID!=0) or (@payCycleID=0))	
		and ((ewh.DateFrom<=@toDate and ewh.DateTo>=@startDate) or (ewh.DateFrom<=@toDate and ewh.DateTo is null))
		and ewh.ID in (select * from fnGetWorkHourHeaderInPeriod(e.EmpID, @startDate, @toDate))
		and dbo.fnGetHoursInDay (e.EmpID, h.Date) is not null		
		and h.Date>=@startDate and h.Date<=@toDate		
UNION
	select
		e.EmpID as EmpID,
		e.displayname as displayname,
		e.surname as surname,

		isnull(e.location,'') as location,
		isnull(e.empstatus,'') as empstatus,
		isnull(e.emptype,'') as emptype,
		e.title as title,
		isnull(e.orgunit2,'') as orgunit2,
		isnull(e.orgunit3,'') as orgunit3,
		lr.ID as ID,
		lrd.LeaveDateFrom as StartDate,
		lrd.LeaveDateTo as EndDate,
		cast (DATENAME(dw, lrd.leavedatefrom) as varchar) as daycode,		
		lt.systemcode+':'+cast (lrd.Duration as varchar) as hours,
		dbo.fnGetWeekByHeaderDate(lr.EmployeeWorkHoursHeaderID, lrd.leavedatefrom) as _week,
		0 as weekmode,
		lt.BackgroundColour as color,
		1 as isLeave	
	from  
		#empList e
		inner join TimesheetHeader th on e.EmpID= th.EmployeeID
		inner join TimesheetDay td on td.TimesheetHeaderID= th.ID
		
		inner join LeaveRequest lr on e.EmpID= lr.EmployeeID
		inner join LeaveRequestDetail lrd on lr.ID= lrd.LeaveRequestID
		inner join LeaveType lt on lr.LeaveTypeID= lt.ID
		inner join LeaveStatus ls on lr.LeaveStatusID= ls.ID
	where 		
		((td.Date<=@toDate and td.Date>=@startDate))	
		and (lrd.LeaveDateFrom <=@toDate and lrd.LeaveDateFrom>=@startDate)
		and ((ls.Code='A' and @leaveNotYetApprove=0) or (@leaveNotYetApprove=1))
		--and lr.IsCancelled=0
		) 
		as r
		order by r.EmpID, r.StartDate
	--select * from #tempEmp
	
	declare @temp_date datetime;
	declare @temp_id int;
	set @temp_id=1;
	set @temp_date= @startDate;
	while (@temp_date<=@toDate) 
	begin		
		insert into @timeTable values (@temp_id, @temp_date, cast(datename(dw, @temp_date)as varchar))
		set @temp_id= @temp_id+1;
		set @temp_date= DATEADD(d, 1, @temp_date);
	end
	select * into #temp from @timeTable 

	select 
	t.EmpID, t.displayname, t.surname, t.location, t.orgunit2,t.orgunit3,t.empstatus, t.emptype, t.title, t.hours as hours, #temp.value, t.color 
	into #result
	from #tempEmp t, #temp
	where t.StartDate= #temp.value
	
	group by t.EmpID, t.displayname, t.surname, t.location, t.orgunit2,t.orgunit3,t.empstatus, t.emptype, t.title,  t.hours,#temp.value,t.color
	order by 		
		t.EmpID, #temp.value, t.color			
	--select * from #result 
	select t.EmpID, t.displayname, t.surname, t.orgunit2 as posorgunit2, t.orgunit3 as posorgunit3, t.location, t.title,
	STUFF ((select ';'+convert(varchar, t1.value, 106)+'_'+ t1.hours from #result t1 where t1.EmpID=t.EmpID for xml path('')),1,1,'') as WorkProfile 
	from #result t
	--where EmpID=794
	group by t.EmpID, t.displayname, t.surname, t.orgunit2,t.orgunit3,t.location,t.title	
	order by 
		CASE WHEN @groupBy = 'posorgunit2' THEN t.orgunit2 END,		
		CASE WHEN @groupBy = 'posorgunit3' THEN t.orgunit3 END,
		CASE WHEN @groupBy = 'location' THEN t.location END, 
		CASE WHEN @groupBy = 'title' or @sortBy='title' THEN t.title END, 
		CASE WHEN @sortBy = 'name' THEN t.displayname END, 
		CASE WHEN @sortBy = 'surname' THEN t.surname END, 
		t.EmpID
	if (OBJECT_ID('tempdb..#tempEmp') is not null)			
		drop table #tempEmp			
	if (OBJECT_ID('tempdb..#empList') is not null)			
		drop table #empList			
	if (OBJECT_ID('tempdb..#temp') is not null)			
		drop table #temp	
	if (OBJECT_ID('tempdb..#result') is not null)			
		drop table #result	
END

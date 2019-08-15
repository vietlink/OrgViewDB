/****** Object:  Procedure [dbo].[uspGetWorkContactForQRReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetWorkContactForQRReport](@empID int, @chkSwipe int, @sortBy varchar(50), @statusList varchar(max), @divisionList varchar(max), @departmentList varchar(max), @locationList varchar(max), @showGroups bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @divisionTable TABLE(division varchar(max));
	DECLARE @statusTable TABLE(status varchar(max));
	DECLARE @departmentTable TABLE(department varchar(max));	
	DECLARE @locationTable TABLE(location varchar(max));
	--DECLARE @employeeStatusTable TABLE(employeeStatus varchar(max));	
	

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

	IF CHARINDEX(',', @departmentList, 0) > 0 BEGIN
		INSERT INTO @departmentTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@departmentList, ',');	
    END
    ELSE IF LEN(@departmentList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @departmentTable(department) VALUES(@departmentList);	
    END

	IF CHARINDEX(';', @locationList, 0) > 0 BEGIN
		INSERT INTO @locationTable-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@locationList, ';');	
    END
    ELSE IF LEN(@locationList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @locationTable(location) VALUES(@locationList);	
    END

	SELECT
		e.displayname,
		case when p.isplaceholder = 0 then p.title else '' end as positiontitle,
		p.orgunit2 as Division,
		p.orgunit3 as Department,
		ec.workphone,
		ec.workmobile,
		epi.id,
		epi.positionid,
		epi.employeeid,
		e.identifier,
		e.picture
	FROM
		EmployeePosition epi
	left outer JOIN
		Employee e
		ON e.id = epi.employeeid
	INNER JOIN EmployeeWorkHoursHeader ewh 
		ON e.id=ewh.EmployeeID 
	INNER JOIN
		EmployeeContact ec
	ON
		ec.employeeid = epi.employeeid
	left outer JOIN
		Position p
	ON
		p.id = epi.positionid
	WHERE
		epi.primaryposition = 'y' and epi.isdeleted = 0 
		--and ((dbo.fnGetNearestWorkHeaderInPeriod(e.id, getdate(), '9999-12-11')=ewh.ID and dbo.fnGetWorkHourHeaderIDByDay(e.id, GETDATE()) is null) or (dbo.fnGetWorkHourHeaderIDByDay(e.id, GETDATE())= ewh.id))
		and ((e.id=@empID) or (@empID=0))
		and ((@chkSwipe=1 and dbo.fnGetNearestWorkHeaderInPeriod(e.id, getdate(), '9999-12-11')=ewh.ID) or (@chkSwipe=0 and dbo.fnGetWorkHourHeaderIDByDay(e.id, GETDATE())= ewh.id))
		and (e.Status IN (SELECT [status] FROM @statusTable) OR (SELECT COUNT(*) FROM @statusTable) = 0)
		AND ((SELECT COUNT(*) FROM @departmentTable) = 0 OR case when isnull(p.orgunit3, '') = '' then '(Blank)' else p.orgunit3 end IN (SELECT * FROM @departmentTable))
		AND ((SELECT COUNT(*) FROM @divisionTable) = 0 OR case when isnull(p.orgunit2, '') = '' then '(Blank)' else p.orgunit2 end IN (SELECT * FROM @divisionTable))
		AND ((SELECT COUNT(*) FROM @locationTable) = 0 OR case when isnull(e.location, '') = '' then '(Blank)' else e.location end IN (SELECT * FROM @locationTable)) 
		AND e.displayname <> 'vacant' AND (@showGroups = 1 OR (@showGroups = 0 AND e.isplaceholder = 0))
	ORDER BY		
		CASE WHEN @sortBy = 'displayname' THEN e.displayname END,
		CASE WHEN @sortBy = 'positiontitle' THEN p.title END,
		CASE WHEN @sortBy = 'division' THEN p.orgunit2 END,
		CASE WHEN @sortBy = 'workphone' THEN ec.workphone END,
		CASE WHEN @sortBy = 'workmobile' THEN ec.workmobile END,
		CASE WHEN @sortBy = 'department' THEN p.orgunit3 END,
		CASE WHEN @sortBy = 'surname' THEN e.surname END,
		CASE WHEN @sortBy = 'surname' THEN e.firstname END
END

/****** Object:  Procedure [dbo].[uspGetLeaveRequestsByEmployeeDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetLeaveRequestsByEmployeeDate](@empId int, @holidayRegionID int, @excludeId int, @typeFilter varchar(1000), @dateFrom datetime, @dateTo datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @publicHolidayTypeID int;
	SELECT @publicHolidayTypeID = id FROM LeaveType WHERE systemcode = 'P';
	DECLARE @otherClassify int = 5;
	DECLARE @idTable TABLE(id int);
	
	IF CHARINDEX(',', @typeFilter, 0) > 0 BEGIN
		INSERT INTO @idTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS int) FROM fnSplitString(@typeFilter, ',');
	--	INSERT INTO @idTable SELECT @publicHolidayTypeID;
    END
    ELSE IF LEN(@typeFilter) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @idTable(id) VALUES(CAST(@typeFilter AS int));
	--	INSERT INTO @idTable SELECT @publicHolidayTypeID;
    END

	DECLARE @dateTable TABLE ([date] DateTime);

	DECLARE @StartDate DATE = @dateFrom;
	DECLARE @EndDate DATE = @dateTo;

	INSERT INTO @dateTable SELECT  DATEADD(DAY, nbr - 1, @StartDate)
	FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY c.object_id ) AS Nbr
			  FROM      sys.columns c
			) nbrs
	WHERE   nbr - 1 <= DATEDIFF(DAY, @StartDate, @EndDate)

	SELECT
		0 as EmployeeID,
		h.[Description] as Title,
		t.[Description] as LeaveType,
		t.SystemCode as LeaveTypeCode,
		t.BackgroundColour,
		t.FontColour,
		'' as LeaveStatus,
		'' as ReasonForLeave,
		'' as LeaveContactDetails,
		'' as ApproverComments,
		0 as TimePeriodRequested,
		h.[Date] as DateFrom,
		h.[Date] as DateTo,
		0 as ExclWeekends,
		0 as ExclPublicHolidays,
		0 as WorkHours,
		0 as ActualHours,
		1 as Days,
		0 as RequestID,
		'' as leavestatusshortdescription
	FROM
		@dateTable dt
	INNER JOIN
		Holiday h
	ON
		dt.[date] = h.[Date]
	INNER JOIN
		LeaveType t
	ON
		t.ID = @publicHolidayTypeID
	WHERE
		h.HolidayRegionID = dbo.fnGetHolidayRegionIDByDay(@empId, dt.[date]) AND
		((SELECT COUNT(*) FROM @idTable) = 0 OR t.ID IN (SELECT lt2.id FROM @idTable idt INNER JOIN LeaveType lt ON lt.id = idt.id INNER JOIN LeaveType lt2 ON lt2.LeaveClassify = lt.LeaveClassify WHERE lt2.ID = idt.id OR lt2.LeaveClassify <> @otherClassify))
	UNION ALL
    SELECT
		r.EmployeeID,
		'' as Title,
		t.[Description] as LeaveType,
		t.SystemCode as LeaveTypeCode,
		t.BackgroundColour,
		t.FontColour,
		s.[Description] as LeaveStatus,
		r.ReasonForLeave,
		r.LeaveContactDetails,
		isnull(r.ApproverComments, '') as ApproverComments,
		r.TimePeriodRequested,
		rd.LeaveDateFrom as DateFrom,
		rd.LeaveDateTo as DateTo,
		r.ExclWeekends,
		r.ExclPublicHolidays,
		ewh.WorkHours,
		CAST(rd.Duration as decimal(18,5)) as ActualHours,
		DATEDIFF(day, r.DateFrom, r.DateTo) as Days,
		r.ID as RequestID,
		s.shortdescription as leavestatusshortdescription
	FROM
		LeaveRequest r
	INNER JOIN
		LeaveRequestDetail rd
	ON
		rd.LeaveRequestID = r.Id
	INNER JOIN
		@dateTable dt
	ON
		dt.[date] = CAST(rd.LeaveDateFrom AS date)
	INNER JOIN
		LeaveType t
	ON
		r.LeaveTypeID = t.ID
	INNER JOIN
		LeaveStatus s
	ON
		r.LeaveStatusID = s.ID
	INNER JOIN
		EmployeeWorkHours ewh
	ON
	 	ewh.EmployeeID = r.EmployeeID AND ewh.DayCode = DATENAME(dw, rd.LeaveDateFrom)
	WHERE
		r.IsCancelled = 0 AND
		r.EmployeeID = @empId AND r.id <> @excludeId AND ewh.EmployeeWorkHoursHeaderID = r.EmployeeWorkHoursHeaderID AND
		ewh.[week] = dbo.fnGetWeekByHeaderDate(rd.EmployeeWorkHoursHeaderID, rd.LeaveDateFrom) AND ewh.[Enabled] = 1
		AND ((SELECT COUNT(*) FROM @idTable) = 0 OR r.LeaveTypeID IN (SELECT lt2.id FROM @idTable idt INNER JOIN LeaveType lt ON lt.id = idt.id INNER JOIN LeaveType lt2 ON lt2.LeaveClassify = lt.LeaveClassify WHERE lt2.ID = idt.id OR lt2.LeaveClassify <> @otherClassify))
END

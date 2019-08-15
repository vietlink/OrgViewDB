/****** Object:  Procedure [dbo].[uspGetLeaveRequestDaysInRange]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetLeaveRequestDaysInRange](@empId int, @dateFrom datetime, @dateTo datetime, @headerId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @reportDesc varchar(100) = '';
	SELECT @reportDesc = ReportDescription FROM LeaveType WHERE SystemCode = 'P'

--	DECLARE @holidayRegionId int = 0;
--	DECLARE @hasPublicHolidays bit;

	-- remove the headerId and holidayRegionId, needs to be more dynamic for cross profile support.

--	SELECT @holidayRegionId = HolidayRegionID, @HasPublicHolidays = HasPublicHolidays FROM EmployeeWorkHoursHeader WHERE ID = @headerId

    SELECT
		lrd.LeaveDateFrom,
		lrd.Duration,
		lt.ReportDescription as ReportDescription,
		ls.Code
	FROM
		LeaveRequestDetail lrd
	INNER JOIN
		LeaveRequest lr
	ON
		lrd.LeaveRequestID = lr.ID
	INNER JOIN
		LeaveStatus ls
	ON
		lr.LeaveStatusID = ls.ID
	INNER JOIN
		LeaveType lt
	ON
		lr.LeaveTypeID = lt.ID
	WHERE	
		lr.EmployeeID = @empId AND (ls.Code = 'A' OR ls.Code = 'P') AND lrd.LeaveDateFrom >= @dateFrom AND lrd.LeaveDateFrom <= @dateTo
--	ORDER BY
	--	lt.ReportDescription

	UNION
	SELECT
		h.[Date] as LeaveDateFrom,
		ISNULL(dbo.fnGetHoursInDay(@empId, h.[Date]), 0) as Duration,
		@reportDesc As ReportDescription,
		'H' as Code
	FROM
		EmployeeWorkHoursHeader ewh
	INNER JOIN
		HolidayRegion hr
	ON
		hr.ID = ewh.HolidayRegionID
	INNER JOIN
		Holiday h
	ON
		h.HolidayRegionID = hr.ID
	WHERE
		--ewh.ID = dbo.fnGetWorkHourHeaderIDByDay(ewh.EmployeeID, h.[Date]) AND
		(h.[Date] >= @dateFrom AND h.[Date] <= @dateTo) AND ewh.HasPublicHolidays = 1
		AND ewh.EmployeeID = @empId
		AND 
		(
			(ewh.DateFrom <= @dateFrom AND ISNULL(ewh.DateTo, '2222-01-01') >= @dateFrom) OR -- @dateFrom between profile
			(ewh.DateFrom <= @dateTo AND ISNULL(ewh.DateTo, '2222-01-01') >= @dateTo) OR -- @dateTo between profile
			(@dateFrom <= ewh.DateFrom AND @dateTo >= ewh.DateFrom) OR -- profile start between @dateFrom and @dateTo
			(@dateFrom <= ISNULL(ewh.DateTo, '2222-01-01') AND @dateTo >= ISNULL(ewh.DateTo, '2222-01-01')) -- profile end between @dateFrom and @dateTo
		)

	ORDER BY
		ReportDescription
		
END

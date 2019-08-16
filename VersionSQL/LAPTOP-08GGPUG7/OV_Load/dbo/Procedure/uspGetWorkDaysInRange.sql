/****** Object:  Procedure [dbo].[uspGetWorkDaysInRange]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[uspGetWorkDaysInRange](@empId int, @dateFrom datetime, @dateTo datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @scanStart datetime = @dateFrom;
	DECLARE @scanEnd datetime = @dateTo;

	CREATE TABLE #dateRange ( dateValue datetime ) ;

	INSERT INTO #dateRange
	SELECT  DATEADD(DAY, nbr - 1, @scanStart)
	FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY c.object_id ) AS Nbr
			  FROM      sys.columns c
			) nbrs
	WHERE   nbr - 1 <= DATEDIFF(DAY, @scanStart, @scanEnd)

	SELECT *, @empId as employeeid
	FROM #dateRange
	OUTER APPLY
	dbo.fnGetWorkDayData(@empId, dateValue, dbo.fnGetWorkHourHeaderIDByDay(@empId, dateValue))
	DROP TABLE #dateRange;
END

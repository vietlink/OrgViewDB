/****** Object:  Procedure [dbo].[uspValidateNewSecondaryPosition]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspValidateNewSecondaryPosition](@editId int, @employeeid int, @positionid int, @datefrom datetime, @dateto datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @searchId int = null;

	SELECT
		@searchId = eph.id
	FROM
		EmployeePositionHistory eph
	WHERE
		eph.Employeeid = @employeeid AND eph.positionid = @positionid
		AND
		((eph.StartDate BETWEEN @datefrom AND isnull(@dateto, '12-31-9999'))
		OR
		eph.EndDate BETWEEN @datefrom AND isnull(@dateto, '12-31-9999')
		OR
		(eph.EndDate = @dateto OR eph.StartDate = @datefrom)
		OR eph.enddate is null and eph.startdate <= @datefrom)
		AND eph.id <> @editId;

	SELECT ISNULL(@searchId, 0) as result
	
END

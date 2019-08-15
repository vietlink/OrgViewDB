/****** Object:  Procedure [dbo].[uspGetComplianceStatsFromPos]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetComplianceStatsFromPos](@employeeId int, @positionId int, @expDays int, @onlyRequirements bit = 1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @validCount int = 0;

	SELECT
		@validCount = count(*)
	FROM
		EmployeeCompetencyList ecl
		LEFT OUTER JOIN EmployeeComplianceHistory ech ON ecl.id= ech.EmployeeCompetencyListID
	INNER JOIN
		CompetencyList cl
	ON
		cl.id = ecl.CompetencyListId
	INNER JOIN
		Competencies c
	ON
		c.id = cl.CompetencyId
	INNER JOIN
		EmployeePosition ep
	ON
		ep.EmployeeID = ecl.Employeeid
	WHERE
		ep.IsDeleted = 0 AND ep.PositionID = @positionid AND ecl.Employeeid = @employeeId AND c.[Type] = 2 AND ecl.IsMandatory = 1 AND (@onlyRequirements = 0 OR (@onlyRequirements = 1 AND ecl.IsPositionRequirement = 1))
		AND
		((((cast(DATEADD(d,0,DATEDIFF(d,0,GETDATE())) as date))  BETWEEN ecl.DateFrom AND ecl.DateTo) 
		AND (DATEADD(day, c.DueToExpireDays, GETDATE()) <= ecl.DateTo)) OR ech.DoesNotExpire=1)

	DECLARE @expireSoonCount int = 0;
	SELECT
		@expireSoonCount = count(*)
	FROM
		EmployeeCompetencyList ecl
	INNER JOIN
		CompetencyList cl
	ON
		cl.id = ecl.CompetencyListId
	INNER JOIN
		Competencies c
	ON
		c.id = cl.CompetencyId
	INNER JOIN
		EmployeePosition ep
	ON
		ep.EmployeeID = ecl.Employeeid
	WHERE
		ep.IsDeleted = 0 AND ep.PositionID = @positionid AND ecl.Employeeid = @employeeId AND c.[Type] = 2 AND ecl.IsMandatory = 1 AND (@onlyRequirements = 0 OR (@onlyRequirements = 1 AND ecl.IsPositionRequirement = 1))
		AND
		(((cast(DATEADD(d,0,DATEDIFF(d,0,GETDATE())) as date)) BETWEEN DateFrom AND DateTo) AND 
		(DATEADD(day, c.DueToExpireDays, GETDATE()) > DateTo))

	DECLARE @expiredCount int = 0;
	SELECT
		@expiredCount = count(*)
	FROM
		EmployeeCompetencyList ecl
		LEFT OUTER JOIN EmployeeComplianceHistory ech ON ecl.id= ech.EmployeeCompetencyListID
	INNER JOIN
		CompetencyList cl
	ON
		cl.id = ecl.CompetencyListId
	INNER JOIN
		Competencies c
	ON
		c.id = cl.CompetencyId
	INNER JOIN
		EmployeePosition ep
	ON
		ep.EmployeeID = ecl.Employeeid
	WHERE
		ep.IsDeleted = 0 AND ep.PositionID = @positionid AND ecl.Employeeid = @employeeId AND c.[Type] = 2 AND ecl.IsMandatory = 1 AND (@onlyRequirements = 0 OR (@onlyRequirements = 1 AND ecl.IsPositionRequirement = 1))
		AND
		((((cast(DATEADD(d,0,DATEDIFF(d,0,GETDATE())) as date))  NOT BETWEEN ecl.DateFrom AND ecl.DateTo) OR ecl.DateFrom IS NULL) AND ech.DoesNotExpire=0)

	DECLARE @validCountOptional int = 0;

	SELECT
		@validCountOptional = count(*)
	FROM
		EmployeeCompetencyList ecl
		LEFT OUTER JOIN EmployeeComplianceHistory ech ON ecl.id= ech.EmployeeCompetencyListID
	INNER JOIN
		CompetencyList cl
	ON
		cl.id = ecl.CompetencyListId
	INNER JOIN
		Competencies c
	ON
		c.id = cl.CompetencyId
	INNER JOIN
		EmployeePosition ep
	ON
		ep.EmployeeID = ecl.Employeeid
	WHERE
		ep.IsDeleted = 0 AND ep.PositionID = @positionid AND ecl.Employeeid = @employeeId AND c.[Type] = 2 AND ecl.IsMandatory = 0 AND (@onlyRequirements = 0 OR (@onlyRequirements = 1 AND ecl.IsPositionRequirement = 1))
		AND
		((((cast(DATEADD(d,0,DATEDIFF(d,0,GETDATE())) as date))  BETWEEN ecl.DateFrom AND ecl.DateTo) 
		AND DATEADD(day, c.DueToExpireDays, GETDATE()) <= ecl.DateTo) OR ech.DoesNotExpire=1)

	DECLARE @expireSoonCountOptional int = 0;
	SELECT
		@expireSoonCountOptional = count(*)
	FROM
		EmployeeCompetencyList ecl
	INNER JOIN
		CompetencyList cl
	ON
		cl.id = ecl.CompetencyListId
	INNER JOIN
		Competencies c
	ON
		c.id = cl.CompetencyId
	INNER JOIN
		EmployeePosition ep
	ON
		ep.EmployeeID = ecl.Employeeid
	WHERE
		ep.IsDeleted = 0 AND ep.PositionID = @positionid AND ecl.Employeeid = @employeeId AND c.[Type] = 2 AND ecl.IsMandatory = 0 AND (@onlyRequirements = 0 OR (@onlyRequirements = 1 AND ecl.IsPositionRequirement = 1))
		AND
		(((cast(DATEADD(d,0,DATEDIFF(d,0,GETDATE())) as date)) BETWEEN DateFrom AND DateTo) 
		AND (DATEADD(day, c.DueToExpireDays, GETDATE()) > DateTo))

	DECLARE @expiredCountOptional int = 0;
	SELECT
		@expiredCountOptional = count(*)
	FROM
		EmployeeCompetencyList ecl
		LEFT OUTER JOIN EmployeeComplianceHistory ech ON ecl.id= ech.EmployeeCompetencyListID
	INNER JOIN
		CompetencyList cl
	ON
		cl.id = ecl.CompetencyListId
	INNER JOIN
		Competencies c
	ON
		c.id = cl.CompetencyId
	INNER JOIN
		EmployeePosition ep
	ON
		ep.EmployeeID = ecl.Employeeid
	WHERE
		ep.IsDeleted = 0 AND ep.PositionID = @positionid AND ecl.Employeeid = @employeeId AND c.[Type] = 2 AND ecl.IsMandatory = 0 AND (@onlyRequirements = 0 OR (@onlyRequirements = 1 AND ecl.IsPositionRequirement = 1))
		AND
		((((cast(DATEADD(d,0,DATEDIFF(d,0,GETDATE())) as date))  NOT BETWEEN ecl.DateFrom AND ecl.DateTo) OR ecl.DateFrom IS NULL) AND ech.DoesNotExpire=0)

	SELECT
		ISNULL(@validCount, 0) as ValidCount,
		ISNULL(@expireSoonCount, 0) as ExpireSoonCount,
		ISNULL(@expiredCount, 0) as ExpiredCount,
		ISNULL(@validCountOptional, 0) as ValidCountOptional,
		ISNULL(@expireSoonCountOptional, 0) as ExpireSoonCountOptional,
		ISNULL(@expiredCountOptional, 0) as ExpiredCountOptional
END

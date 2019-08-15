/****** Object:  Procedure [dbo].[uspGetDueOrExpiringComplianceList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetDueOrExpiringComplianceList](@dueDays int, @checkNotificationDays int, @daysAfter int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		e.id as employeeid,
		e.displayname as name,
		isnull(e.surname, '') as surname,
		c.Id as competencyid,
		c.[Description] as competency,
		ecl.DateFrom,
		ecl.DateTo,
		case when p.isplaceholder = 0 then p.title else '' end as position,
		cg.[Description] as Folder,
		ISNULL(DATEDIFF(day, GETDATE(), ecl.DateTo), 0) as expireDays,
		ecl.IsPositionRequirement,
		ec.WorkEmail,
		CASE
		WHEN (Convert(DateTime, DATEDIFF(DAY, 0, GETDATE())) NOT BETWEEN ecl.DateFrom AND ecl.DateTo) THEN 'after'
		WHEN ecl.DateTo IS NULL and ech.DoesNotExpire=0 THEN 'after'
		WHEN DATEDIFF(day, GETDATE(), ecl.DateTo) =1 or DATEDIFF(day, getdate(), ecl.dateto)=0 then 'expired'
		WHEN DATEDIFF(day, GETDATE(), ecl.DateTo) = @dueDays and DATEDIFF(day, GETDATE(), ecl.DateTo)>1 THEN 'due'
		END as compliantType,
		ISNULL(u.id, 0) as userId,
		ecl.Id as eclId,
		isnull(eM.id, '') as managerID,
		isnull(eM.displayname,'') as managerName,
		isnull(ecM.workemail,'') as managerWorkEmail
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
			c.id = cl.competencyid
		INNER JOIN
			CompetencyGroups cg
		ON
			cg.id = cl.competencygroupid
		INNER JOIN
			Employee e
		ON
			e.id = ecl.Employeeid
		INNER JOIN
			EmployeePosition ep
		ON
			ep.employeeid = e.id
		INNER JOIN
			EmployeePosition empPos
		ON
			ep.id = empPos.id AND empPos.primaryposition = 'Y'
		INNER JOIN
			Position p
		ON
			p.id = ep.positionid
		LEFT OUTER JOIN 
			EmployeePosition epM 
		ON 
			ep.ManagerID= epM.id
		LEFT OUTER JOIN Employee eM ON eM.id= epM.employeeid
		LEFT OUTER JOIN EmployeeContact ecM ON eM.id= ecM.employeeid
		INNER JOIN
			EmployeeContact ec
		ON
			ec.Employeeid = e.id
		LEFT OUTER JOIN
			[User] U
		ON
			u.displayname = e.displayname		
		WHERE
			ecl.IsMandatory = 1 AND ep.primaryposition = 'y' and ep.isdeleted = 0 and e.identifier <> 'Vacant'  AND c.[Type] = 2 AND c.[Type] = 2 AND e.IsDeleted = 0 AND (DATEDIFF(day, GETDATE(), ecl.DateTo) <= @dueDays OR ecl.DateFrom IS NULL)
		ORDER BY e.ID, DATEDIFF(day, GETDATE(), ecl.DateTo), e.surname, c.[Description] ASC
END

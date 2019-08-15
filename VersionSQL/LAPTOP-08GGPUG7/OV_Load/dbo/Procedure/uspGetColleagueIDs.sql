/****** Object:  Procedure [dbo].[uspGetColleagueIDs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetColleagueIDs](@empPosId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT ep.id FROM EmployeePosition ep
	INNER JOIN
	Position p
	ON p.id = ep.positionid
	INNER JOIN
	Employee e
	ON e.id = ep.employeeid
	INNER JOIN
	[Status] s
	ON s.[Description] = e.[status]
	WHERE e.isplaceholder = 0 and s.IsVisibleChart = 1 AND ep.IsDeleted = 0 AND p.IsDeleted = 0 AND e.IsDeleted = 0 AND p.IsUnassigned = 0 AND p.parentid IN(
		SELECT p.parentid FROM EmployeePosition ep
		INNER JOIN
		Position p
		ON
		p.id = ep.positionid
		WHERE ep.id = @empPosId AND p.IsUnassigned = 0
	)
END

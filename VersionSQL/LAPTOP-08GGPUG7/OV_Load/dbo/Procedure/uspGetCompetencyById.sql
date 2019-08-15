/****** Object:  Procedure [dbo].[uspGetCompetencyById]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetCompetencyById](@id int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT c.Id, c.Code,c.Description, c.DoesNotExpire, c.Enabled, c.SortOrder, c.Type, c.ComplianceScoreType,
	case when c.DueToExpireDays=0 then cnd.DefaultDueToExpireDays else c.DueToExpireDays end as DueToExpireDays
	, ISNULL(ComplianceScoreRange, 0) as ComplianceScoreRangeN,
	(SELECT COUNT(cl.id) FROM CompetencyList cl	INNER JOIN EmployeeCompetencyList ecl ON cl.id = ecl.CompetencyListId WHERE cl.CompetencyId = @id) as EmployeeCount,
	(SELECT COUNT(cl.id) FROM CompetencyList cl INNER JOIN Competencies c ON c.id = cl.CompetencyId INNER JOIN PositionCompetencyList pcl ON cl.id = pcl.CompetencyListId WHERE cl.CompetencyId = @id) AS PositionCount
	FROM Competencies c , ComplianceNotificationDetails cnd
	WHERE c.Id = @id;
END

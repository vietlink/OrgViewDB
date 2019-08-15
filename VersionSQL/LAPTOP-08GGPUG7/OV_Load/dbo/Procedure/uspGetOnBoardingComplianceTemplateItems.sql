/****** Object:  Procedure [dbo].[uspGetOnBoardingComplianceTemplateItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingComplianceTemplateItems](@templateId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		obc.*, c.[Description] as Compliance
	FROM
		OnBoardingComplianceTemplateItems obc 
	INNER JOIN
		CompetencyList cl
	ON
		cl.ID = obc.ComplianceListID
	INNER JOIN
		Competencies c
	ON
		c.ID = cl.CompetencyId
	WHERE 
		OnBoardingComplianceTemplateID = @templateId ORDER BY SortOrder ASC
END


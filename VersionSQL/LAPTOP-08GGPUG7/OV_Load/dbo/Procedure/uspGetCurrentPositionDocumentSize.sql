/****** Object:  Procedure [dbo].[uspGetCurrentPositionDocumentSize]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetCurrentPositionDocumentSize](@positionid int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
		ISNULL(SUM(CAST(d.Size as int)), 0) as Size
	FROM
		Documents d
	LEFT OUTER JOIN
		PositionCompetencyList pcl
	ON
		pcl.Id = d.DataID AND d.PageType LIKE 'PositionCompetency'
	WHERE
		d.IsDeleted = 0 AND (pcl.PositionID = @positionid OR (d.DataID = @positionid AND d.PageType LIKE 'PositionCompetency'))
END


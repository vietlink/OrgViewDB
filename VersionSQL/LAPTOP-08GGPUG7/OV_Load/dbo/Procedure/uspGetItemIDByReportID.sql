/****** Object:  Procedure [dbo].[uspGetItemIDByReportID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Linh Ngo
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspGetItemIDByReportID
	-- Add the parameters for the stored procedure here
	@reportID int, @attributeID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT isnull(dri.ID,0) as id
	FROM DynamicReportItems dri
	WHERE dri.DynamicReportHeaderID= @reportID
	AND dri.AttributeID= @attributeID
END

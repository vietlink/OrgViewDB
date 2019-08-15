/****** Object:  Procedure [dbo].[uspGetAttributeIDByReportID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Linh Ngo
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspGetAttributeIDByReportID 
	-- Add the parameters for the stored procedure here
	@reportID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT dri.AttributeID
	FROM DynamicReportItems dri
	WHERE dri.DynamicReportHeaderID= @reportID
END

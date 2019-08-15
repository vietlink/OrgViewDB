/****** Object:  Procedure [dbo].[uspDeleteDynamicReportByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Linh Ngo
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspDeleteDynamicReportByID 
	-- Add the parameters for the stored procedure here
	@reportID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM DynamicReportItems
	WHERE DynamicReportHeaderID= @reportID
	DELETE FROM DynamicReportHeader
	WHERE ID= @reportID
END

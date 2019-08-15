/****** Object:  Procedure [dbo].[uspGetDynamicReportByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Linh Ngo
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspGetDynamicReportByID 
	-- Add the parameters for the stored procedure here
	@reportID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT drh.Name, dri.*
	FROM DynamicReportHeader drh
	INNER JOIN DynamicReportItems dri ON drh.ID= dri.DynamicReportHeaderID
	WHERE drh.ID= @reportID
	order by dri.ColumnOrder
END

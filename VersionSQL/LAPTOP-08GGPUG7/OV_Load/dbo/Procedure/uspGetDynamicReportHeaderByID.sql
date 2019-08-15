/****** Object:  Procedure [dbo].[uspGetDynamicReportHeaderByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Linh Ngo
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspGetDynamicReportHeaderByID 
	-- Add the parameters for the stored procedure here
	@id int, @filter varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * 
	FROM DynamicReportHeader drh
	WHERE (drh.id= @id OR @id=0)
	AND drh.Name like '%'+@filter+'%' 

END

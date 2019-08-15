/****** Object:  Procedure [dbo].[uspAddOrUpdateDynamicReportHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Linh Ngo
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspAddOrUpdateDynamicReportHeader] 
	-- Add the parameters for the stored procedure here
	@reportID int, @reportName varchar(max), @ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (@reportID=0) 
	BEGIN
		INSERT INTO DynamicReportHeader (Name) VALUES (@reportName)
		SET @ReturnValue= @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE DynamicReportHeader
		SET Name= @reportName
		WHERE ID= @reportID
		SET @ReturnValue= @reportID
	END
	
END

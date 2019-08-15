/****** Object:  Procedure [dbo].[uspUpdateLastSentComplianceEmp]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspUpdateLastSentComplianceEmp
	-- Add the parameters for the stored procedure here
	@date datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE ComplianceNotificationDetails
	SET LastSentDateEmp = @date
END

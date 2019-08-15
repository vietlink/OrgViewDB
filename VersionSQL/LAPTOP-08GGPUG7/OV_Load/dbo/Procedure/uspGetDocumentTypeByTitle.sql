/****** Object:  Procedure [dbo].[uspGetDocumentTypeByTitle]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetDocumentTypeByTitle] 
	-- Add the parameters for the stored procedure here
	@filter varchar(50), @status bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here	
		SELECT ID, Code as DocTypeCode, Description as DocTypeDesc, Title as DocTypeTitle, Editable, isDeleted from DocumentTypes where Title=@filter and IsDeleted= @status
	
END

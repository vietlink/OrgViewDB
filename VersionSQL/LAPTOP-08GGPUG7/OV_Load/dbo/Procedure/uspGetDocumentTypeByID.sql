/****** Object:  Procedure [dbo].[uspGetDocumentTypeByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetDocumentTypeByID] 
	-- Add the parameters for the stored procedure here
	@id int, @filter varchar(300), @status bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (@id=0) begin
		SELECT ID, Code as DocTypeCode, Comments as DocTypeDesc, Description as DocTypeTitle, Editable, isDeleted from DocumentTypes
		where (Code like '%'+@filter+'%' or Description like '%'+@filter+'%')
		and IsDeleted= @status
	end
	else begin
		SELECT ID, Code as DocTypeCode, Comments as DocTypeDesc, Description as DocTypeTitle, Editable, isDeleted from DocumentTypes where ID=@id and IsDeleted= @status
	end
END

/****** Object:  Procedure [dbo].[uspIsDeletedDocumentType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspIsDeletedDocumentType] 
	-- Add the parameters for the stored procedure here
	@docTypeCode varchar(50) , 
	@ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @ReturnValue= (select isnull(IsDeleted,0) 
	from DocumentTypes
	where Code=@docTypeCode )
END


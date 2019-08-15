/****** Object:  Procedure [dbo].[uspIsUsedDocumentType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
create PROCEDURE [dbo].[uspIsUsedDocumentType] 
	-- Add the parameters for the stored procedure here
	@docTypeCode varchar(50) , 
	@ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @ReturnValue= (select count(*) 
	from Documents
	where PageType=@docTypeCode )
END


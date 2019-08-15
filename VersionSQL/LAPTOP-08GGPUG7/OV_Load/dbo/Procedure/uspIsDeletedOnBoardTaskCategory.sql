/****** Object:  Procedure [dbo].[uspIsDeletedOnBoardTaskCategory]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
create PROCEDURE [dbo].[uspIsDeletedOnBoardTaskCategory] 
	-- Add the parameters for the stored procedure here
	@description varchar(100) , 
	@ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @ReturnValue= (select isnull(IsDeleted,0) 
	from OnBoardingTaskCategories
	where description=@description)
END


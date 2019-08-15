/****** Object:  Procedure [dbo].[uspAddOrUpdateOnBoardTaskCategory]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspAddOrUpdateOnBoardTaskCategory] 
	-- Add the parameters for the stored procedure here
	@id int , 
	@description varchar(100),
	
	@ReturnValue int output 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here	
	IF (@id=0) BEGIN
		INSERT INTO OnBoardingTaskCategories (description) 
		VALUES (@description)
		SET @ReturnValue= @@IDENTITY					
	END
	ELSE
	BEGIN
		
		update OnBoardingTaskCategories
		set Description= @description
		where ID=@id
		SET @ReturnValue= @id

		
	END
-- update related table needed
	
END

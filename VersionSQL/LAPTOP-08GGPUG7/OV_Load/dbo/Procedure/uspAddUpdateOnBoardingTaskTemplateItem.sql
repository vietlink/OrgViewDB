/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingTaskTemplateItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingTaskTemplateItem](@id int, @templateId int, @onBoardingTaskId int, @sortOrder int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    IF @id = 0 BEGIN
		INSERT INTO 
			OnBoardingTaskTemplateItems(OnBoardingTaskTemplateID, OnBoardingTaskID, SortOrder)
				VALUES(@templateId, @onBoardingTaskId, @sortOrder)
	END ELSE BEGIN
		UPDATE
			OnBoardingTaskTemplateItems
		SET
			SortOrder = @sortOrder
		WHERE
			ID = @id;
	END
END

